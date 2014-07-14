package com.mathgames.api.local.qpanel
{
    import flash.display.*;
    import flash.geom.*;

    final public class ScaledRenderTarget
    {
        private var _boundsWidth :Number;
        private var _boundsHeight :Number;
        private var _boundsX :Number;
        private var _boundsY :Number;
        private var _boundsParent :DisplayObjectContainer;

        private var _color :ColorTransform;
        private var _filters :Array;
        private var _child :DisplayObject;
        private var _enabled :Boolean;

        public function ScaledRenderTarget (bounds:DisplayObject, color:ColorTransform = null, filters:Array = null)
        {
            _boundsWidth = bounds.width;
            _boundsHeight = bounds.height;
            _boundsX = bounds.x;
            _boundsY = bounds.y;
            _boundsParent = bounds.parent;
            _color = color;
            _filters = filters;

            bounds.visible = false;

            _child = null;
            _enabled = true;
        }

        public function getScaleRatio (displayObject:DisplayObject) :Number
        {
            var xRatio :Number = _boundsWidth  / displayObject.width;
            var yRatio :Number = _boundsHeight / displayObject.height;
            return Math.min (xRatio, yRatio);
        }

        public function show (bitmapData:BitmapData, forceRatio:Number = -1) :void
        {
            if (!_enabled) return;

            if (_child) _boundsParent.removeChild (_child);

            var displayObject :Bitmap = new Bitmap (bitmapData, "auto", true);

            if (_color) displayObject.transform.colorTransform = _color;

            if (_filters && _filters.length > 0) {
                var childSprite :Sprite = new Sprite;
                childSprite.addChild (displayObject);
                childSprite.filters = _filters;
                _child = childSprite;
            } else {
                _child = displayObject;
            }

            _boundsParent.addChild (_child);

            var scaleRatio :Number = forceRatio > 0
                                   ? forceRatio
                                   : getScaleRatio (displayObject);

            _child.scaleX = scaleRatio;
            _child.scaleY = scaleRatio;

            _child.x = _boundsX;
            _child.y = _boundsY;
        }

        public function clear () :void
        {
            if (_child) _boundsParent.removeChild (_child);
            _child = null;
        }

        public function clearAndDisable () :void
        {
            clear ();
            _boundsParent = null;
            _enabled = false;
        }
    }
}