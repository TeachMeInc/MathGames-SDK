package com.mathgames.api.local
{
    import flash.events.*;

    final public class MathGamesEvent extends Event
    {
        static public const ERROR :String = "mg-error";
        static public const CONNECTED :String = "mg-connected";

        static public const SKILL_SELECTED :String = "mg-skill-selected";
        static public const SKILL_SELECT_CANCELLED :String = "mg-skill-select-cancel";

        static public const SESSION_READY :String = "mg-session-ready";
        static public const QUESTION_READY :String = "mg-question-ready"; // data : Question

        static public const AVERAGE_TIME_CHANGE :String = "mg-avg-time-change"; // data : int (milliseconds per question)
        static public const PROGRESS_CLOSED :String = "mg-progress-close";

        public var data :Object;

        public function MathGamesEvent (type:String, data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false) {
            this.data = data;
            super (type, bubbles, cancelable);
        }

        public override function clone() :Event {
            return new MathGamesEvent (type, data, bubbles, cancelable);
        }

        public override function toString() :String {
            return formatToString ("MathGamesEvent", "type", "bubbles", "cancelable", "eventPhase");
        }
    }
}
