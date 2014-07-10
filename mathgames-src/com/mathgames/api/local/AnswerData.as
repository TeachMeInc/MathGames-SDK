package com.mathgames.api.local
{
    import flash.display.*;

    public class AnswerData
    {
        public var correct :Boolean;
        public var clickTarget :DisplayObject;
        public var averageAnswerTime :Number;

        public function AnswerData (correct:Boolean, clickTarget:DisplayObject, averageAnswerTime:Number) {
            this.correct = correct;
            this.clickTarget = clickTarget;
            this.averageAnswerTime = averageAnswerTime;
        }
    }
}