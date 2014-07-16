package com.mathgames.api.local.qpanel
{
    import flash.display.*;
    import flash.geom.*;

    final internal class ScaledRenderTarget
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

        public function getScaleRatio (bmpData:BitmapData) :Number
        {
            var xRatio :Number = _boundsWidth  / bmpData.width;
            var yRatio :Number = _boundsHeight / bmpData.height;
            return Math.min (xRatio, yRatio);
        }

        public function show (bitmapData:BitmapData, forceRatio:Number = -1) :void
        {
            if (!_enabled) return;

            if (_child) _boundsParent.removeChild (_child);

            var displayObject :DisplayObject = renderBitmapData (bitmapData);

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
                                   : getScaleRatio (bitmapData);

            _child.scaleX = scaleRatio;
            _child.scaleY = scaleRatio;

            _child.x = _boundsX;
            _child.y = _boundsY;
        }

        static private function renderBitmapData (bmpData:BitmapData) :DisplayObject
        {
            var spr :Sprite = new Sprite;
            var bitmap :Bitmap = new Bitmap (bmpData, "auto", true);

            spr.addChild (bitmap);
            bitmap.x = -bitmap.width / 2;
            bitmap.y = -bitmap.height / 2;
            // disp.z = 1; // Setting the z coord to non-zero forces the Flash Player to use better smoothing when scaling.
            return spr;
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