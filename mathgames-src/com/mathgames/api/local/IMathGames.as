package com.mathgames.api.local
{
    import flash.display.*;
    import flash.events.*;

    /**
     * Defines the interface used by the MathGames singleton.  Coding against this
     * interface rather than MathGames directly allows us to test against an offline
     * version of the API in our games without too much hassle.
     */
    public interface IMathGames extends IEventDispatcher
    {
        function connect (container:DisplayObjectContainer, config:Object) :void;

        function selectSkill () :void;

        function startSession (config:Object) :void;
        function endSession () :void;

        function showSupportedSkillStandards () :void;
        function showProgress () :void;

        function postMetrics (key:String, data:Object) :void;
        function setSoundEnabled (enabled:Boolean) :void;
    }
}
