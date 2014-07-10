package com.mathgames.api.local
{
    import flash.events.*;

    public class MathGamesEvent extends Event
    {
        static public const ERROR :String = "MathGamesEvent.ERROR";
        static public const CONNECTED :String = "MathGamesEvent.CONNECTED";
        static public const AUTHENTICATED :String = "MathGamesEvent.AUTHENTICATED";
        static public const AUTH_CANCELLED :String = "MathGamesEvent.AUTH_CANCELLED";
        static public const LOGOUT :String = "MathGamesEvent.LOGOUT";

        static public const SESSION_READY :String = "MathGamesEvent.SESSION_READY";
        static public const QUESTION_ANSWERED :String = "MathGamesEvent.QUESTION_ANSWERED";

        static public const PROGRESS_OPENED :String = "MathGamesEvent.PROGRESS_OPENED";
        static public const PROGRESS_CLOSED :String = "MathGamesEvent.PROGRESS_CLOSED";


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