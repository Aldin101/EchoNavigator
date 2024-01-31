using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System;

using CefSharp;
using System.Diagnostics;
using System.Net;
using CefSharp.DevTools.Network;
using Newtonsoft.Json.Linq;

namespace Installer
{
    internal class OculusProtocolHandler : CefSharp.Handler.RequestHandler
    {
        public delegate void CallbackEventHandler(string resp, string tok);
        public event CallbackEventHandler UrlCB;
        private string sstoken;
        public OculusProtocolHandler(CallbackEventHandler CB, string token) {
           UrlCB = CB;
           sstoken = token;
        }
       
       protected override bool OnBeforeBrowse(IWebBrowser chromiumWebBrowser, IBrowser browser,
       IFrame frame, IRequest request, bool userGesture, bool isRedirect)
        {
            if (!request.Url.StartsWith("oculus://")) return false;
            Console.WriteLine(request.Url.ToString());
            UrlCB(request.Url.ToString(), sstoken);
            browser.CloseBrowser(false);
            browser.Dispose();
            return true;
        }
    }

}
