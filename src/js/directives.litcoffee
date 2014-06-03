    v3spa = angular.module 'vespa.directives', []

    v3spa.directive 'autoHeight', ($window) ->
      ret =
        restrict: 'A'
        replace: false
        transclude: false
        scope:
          modifier: '@autoHeight'
          type: "@autoHeightType"
          resize_callback: '&onResize'
        controller: ($scope, $element)->
          angular.element($window).bind 'resize', ->
            $scope.$apply ->
              if not $scope.type? or $scope.type == 'percentage'
                $element.height "#{$window.innerHeight * $scope.modifier}px"
              else if $scope.type == 'offset_bottom_px'
                $element.height "#{$window.innerHeight - $scope.modifier}px"

            if $scope.resize_callback
              $scope.resize_callback()
        link: (scope, element, attrs)->
          if not attrs.autoHeightType? or attrs.autoHeightType == 'percentage'
            element.height "#{$window.innerHeight * attrs.autoHeight}px"
          else if attrs.autoHeightType == 'offset_bottom_px'
            element.height "#{$window.innerHeight - attrs.autoHeight}px"
          scope.resize_callback()

      return ret

    v3spa.directive 'spinnerIcon', ->
      ret =
        restrict: 'A'
        replace: true
        transclude: true
        scope: 
          loading: '= spinnerIcon'
          opts: '= opts'
        template:  """
          <div>
            <div class='spinner-container' ng-show='loading'></div>
            <div ng-hide='loading'></div>
          </div>
          """
        link: (scope, element, attrs) ->
          spinner = new Spinner(scope.opts).spin()
          container = element.find('.spinner-container')[0]
          container.appendChild(spinner.el)

      return ret

    v3spa.directive 'fileUploadDrop', ->
      dir = 
        restrict: 'A'
        scope: 
          on_drop: '&fileUploadDrop'
        link: (scope, elem)->
          elem.bind 'drop', (e)->
              dataTrans = e.dataTransfer
              dataTrans ?= e.originalEvent.dataTransfer

              e.preventDefault()
              e.stopPropagation()

              elem.removeClass('file-drop-over')
              method = scope.on_drop()
              method(dataTrans.files[0], elem.attr('name'))

          elem.bind 'dragover', (e)->

            dataTrans = event.dataTransfer
            dataTrans ?= event.originalEvent.dataTransfer

            e.preventDefault()
            e.stopPropagation()

            elem.addClass('file-drop-over')
            dataTrans.dropEffect = 'copy'

          elem.bind 'dragleave', (e)->
            e.preventDefault()
            e.stopPropagation()

            elem.removeClass('file-drop-over')

      return dir

    v3spa.directive 'v3spaEditor', ->
      ret = 
        restrict: 'A'
        replace: true
        scope:
          contents: '='
        template: """
          <div>
          <div></div>
          <div id='v3spaEditor'>
          </div>
          </div>
        """
        link: (scope, element, attrs)->
          editor = ace.edit(element.$('#v3spaEditor'))
          editor.setTheme("ace/theme/chaos");
          editor.setKeyboardHandler("vim");
          editor.setBehavioursEnabled(true);
          editor.setSelectionStyle('line');
          editor.setHighlightActiveLine(true);
          editor.setShowInvisibles(false);
          editor.setDisplayIndentGuides(false);
          editor.renderer.setHScrollBarAlwaysVisible(false);
          editor.setAnimatedScroll(false);
          editor.renderer.setShowGutter(true);
          editor.renderer.setShowPrintMargin(false);
          editor.getSession().setUseSoftTabs(true);
          editor.setHighlightSelectedWord(true);

Set up editor sessions
          lobsterSession = new EditSession scope.contents.dsl, 'ace/mode/lobster'
          lobsterSession.on 'change', (text)->
            $scope.policy.dsl = text

          scope.$watch contents, (contents)->
            lobsterSession.setValue contents

          applicationSession = new EditSession scope.contents.application
          editor.setSession(lobsterSession)

          scope.sessions =  [
            {name: "DSL", session: lobsterSession},
            {name: "application", applicationSession}
          ]

          editor.resize()


      return ret
