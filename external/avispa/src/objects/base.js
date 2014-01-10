// Generated by CoffeeScript 1.6.3
(function() {
  Avispa.BaseObject = Backbone.View.extend({
    events: {
      'mousedown': 'OnMouseDown',
      'mouseenter': 'OnMouseEnter',
      'mouseleave': 'OnMouseLeave',
      'contextmenu': 'OnRightClick'
    },
    initialize: function(options) {
      var position;
      this.options = options;
      _.bindAll(this, 'OnMouseDown');
      position = this.options.position;
      this.parent = this.options.parent;
      if (this.parent) {
        this.offset = {
          x: position.x,
          y: position.y
        };
        position.x += this.parent.position.get('x');
        position.y += this.parent.position.get('y');
        this.parent.position.bind('change', this.ParentDrag, this);
      }
      this.position = new Models.Position(position);
      this.position.bind('change', this.render, this);
      this._init();
      if (typeof this.init === "function") {
        this.init();
      }
      this.render();
      return this;
    },
    ParentDrag: function(ppos) {
      this.position.set({
        x: this.offset.x + ppos.get('x'),
        y: this.offset.y + ppos.get('y')
      });
    },
    OnMouseDown: function(event) {
      this.jitter = 0;
      this.x1 = (event.clientX / context.scale) - this.position.get('x');
      this.y1 = (event.clientY / context.scale) - this.position.get('y');
      if (this.parent) {
        this.ox1 = this.offset.x - this.position.get('x');
        this.oy1 = this.offset.y - this.position.get('y');
      }
      context.dragItem = this;
      return cancelEvent(event);
    },
    Drag: function(event) {
      var x, y;
      x = (event.clientX / context.scale) - this.x1;
      y = (event.clientY / context.scale) - this.y1;
      this.position.set({
        'x': x,
        'y': y
      });
      return cancelEvent(event);
    }
  });

}).call(this);
