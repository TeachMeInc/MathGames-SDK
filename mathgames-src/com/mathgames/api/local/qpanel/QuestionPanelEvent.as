package com.mathgames.api.local.qpanel
{
    import flash.display.*;
    import flash.events.*;

    public class QuestionPanelEvent extends Event
    {
        static public const ANSWER :String = "qp-answer";

        public var clickTarget :DisplayObject;
        public var correct :Boolean;

        public function QuestionPanelEvent (type:String, clickTarget:DisplayObject, correct:Boolean, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super (type, bubbles, cancelable);
            this.clickTarget = clickTarget;
            this.correct = correct;
        }

        public override function clone():Event
        {
            return new QuestionPanelEvent (type, clickTarget, correct, bubbles, cancelable);
        }

        public override function toString():String
        {
            return formatToString ("QuestionAnswerEvent", "type", "clickTarget", "correct", "bubbles", "cancelable", "eventPhase");
        }
    }
}