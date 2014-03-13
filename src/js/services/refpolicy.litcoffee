    mod = angular.module('vespa.services')

    mod.service 'RefPolicy',
      class RefPolicy
        constructor: (@VespaLogger, @SockJSService, @$q, @$timeout)->

          @uploader_running = false
          @chunks_to_upload = []

        upload_chunk: (name, chunk, start, len, total)=>
          deferred = @$q.defer()

          req = 
            domain: 'refpolicy'
            request: 'upload_chunk'
            payload: 
              name: name
              data: chunk
              index: start
              length: len
              total: total

          @chunks_to_upload.push [req, deferred]

If this is the only thing in the queue, start the uploader

          if not @uploader_running
            @uploader_running = true
            @$timeout =>
              @_upload_chunks()

          return deferred.promise

        _upload_chunks: =>

          chunk = @chunks_to_upload.shift()
          req = chunk[0]
          deferred = chunk[1]

          @SockJSService.send req, (data)=>
            if data.error?
              deferred.reject(data.payload)
              @uploader_running = false
              @chunks_to_upload = []
            else
              deferred.resolve(data.payload)
              if @chunks_to_upload.length > 0
                @_upload_chunks()
              else
                @uploader_running = false


        list: =>

          deferred = @$q.defer()

          req = 
            domain: 'refpolicy'
            request: 'find'
            payload: 
              criteria:
                valid: true
              selection:
                id: true


          @SockJSService.send req, (data)->
            if data.error?
              deferred.reject(data.payload)
            else
              deferred.resolve(data.payload)

          return deferred.promise

