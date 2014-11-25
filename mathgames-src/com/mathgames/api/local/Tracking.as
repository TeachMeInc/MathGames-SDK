package com.mathgames.api.local
{
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;

    internal final class Tracking
    {
        public function Tracking()
        {
            throw new Error ("Cannot instantiate static class com.mathgames.api.local.Tracking");
        }

        static public const LOAD_ERROR     :String = "api-load-error";     //initial load failed
        static public const RELOAD_ATTEMPT :String = "api-reload-attempt"; //attempts
        static public const RELOAD_SUCCESS :String = "api-reload-success"; //successfully loaded after retry
        static public const RELOAD_DIALOG  :String = "api-reload-dialog";  //reload dialog shown
        
        static private function trackURL (action:String, apikey:String) :String
        {
            var rand :String = Math.random().toString().substr(2);

            return "https://analytics.mathgames.com/piwik.php?apiv=1&rec=1&idsite=1&_id=1234567898765432&"+
                "url=www.mathgames.com&e_c=api-events&e_a="+action+"&e_n="+apikey+"&rand="+rand;
        }

        static public function trackEvent (action:String, apikey:String="") :void
        {
            var request :URLRequest = new URLRequest (trackURL (action, apikey));
            request.method = URLRequestMethod.GET;

            var loader :URLLoader = new URLLoader();

            function removeListeners (e:Event) :void {
                loader.removeEventListener (Event.COMPLETE, removeListeners);
                loader.removeEventListener (IOErrorEvent.IO_ERROR, removeListeners);
                loader.removeEventListener (SecurityErrorEvent.SECURITY_ERROR, removeListeners);
            }
            loader.addEventListener (Event.COMPLETE, removeListeners);
            loader.addEventListener (IOErrorEvent.IO_ERROR, removeListeners);
            loader.addEventListener (SecurityErrorEvent.SECURITY_ERROR, removeListeners);

            loader.load (request);
        }
    }
}