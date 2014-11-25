package com.mathgames.api.local
{
    import flash.display.*;

    final public class Question
    {
        public var question :BitmapData;
        public var answers :Vector.<BitmapData>;
        public var correctIndex :int;
        public var doAnswer :Function; // (selectedIndex :int) :void
    }
}