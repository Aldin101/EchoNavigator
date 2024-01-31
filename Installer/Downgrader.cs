using Microsoft.Win32;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Linq;
using CefSharp;
using CefSharp.WinForms;
using System.Security.Policy;
using System.Runtime.ConstrainedExecution;
using static System.Windows.Forms.VisualStyles.VisualStyleElement.TextBox;
using CefSharp.DevTools.Network;
using System.Net;
using Newtonsoft.Json;

namespace Installer
{

    internal static class Downgrader
    {
        public static class DowngradeControls
        {
            public static Label downgradeLabel;
            public static Button downgradeButton;
            public static Label segmentLabel;
            public static ProgressBar segmentProgress;
            public static Label sizeLabel;
            public static ProgressBar sizeProgress;
            public static Label timeRemainingLabel;
        }

        public static void Downgrade()
        {
            Form downgradeMenu = new Form
            {
                Text = "Downgrder",
                Size = new Size(240, 200),
                StartPosition = FormStartPosition.CenterScreen,
                FormBorderStyle = FormBorderStyle.FixedDialog,
                ShowInTaskbar = false,
                MaximizeBox = false,
            };

            DowngradeControls.downgradeLabel = new Label
            {
                Text = "Echo Navigator Downgrader",
                Location = new Point(10, 10),
                Size = new Size(200, 20),
                Font = new Font("Arial", 11),
                TextAlign = ContentAlignment.MiddleCenter,
            };


            DowngradeControls.downgradeButton = new Button
            {
                Text = "Downgrade",
                Location = new Point(10, 40),
                Size = new Size(200, 30),
                Font = new Font("Arial", 10),
            };
            DowngradeControls.downgradeButton.Click += (sender, e) => startDowngrade();

            DowngradeControls.segmentLabel = new Label
            {
                Text = "Downloaded Segments",
                Location = new Point(10, 70),
                Size = new Size(200, 20),
                Font = new Font("Arial", 10),
                Visible = false,
            };

            DowngradeControls.segmentProgress = new ProgressBar
            {
                Location = new Point(10, 90),
                Size = new Size(200, 15),
                Visible = false,
            };

            DowngradeControls.sizeLabel = new Label
            {
                Text = "Downloaded Size",
                Location = new Point(10, 110),
                Size = new Size(200, 20),
                Font = new Font("Arial", 10),
                Visible = false,
            };

            DowngradeControls.sizeProgress = new ProgressBar
            {
                Location = new Point(10, 130),
                Size = new Size(200, 15),
                Visible = false,
            };

            DowngradeControls.timeRemainingLabel = new Label
            {
                Text = "Time Till Cancel Option: 1:00",
                Location = new Point(10, 110),
                Size = new Size(200, 20),
                Font = new Font("Arial", 10),
                Visible = false,
            };


            foreach (var field in typeof(DowngradeControls).GetFields())
            {
                var control = field.GetValue(null) as Control;
                if (control != null)
                {
                    downgradeMenu.Controls.Add(control);
                }
            }

            downgradeMenu.ShowDialog();
        }

        private static void startDowngrade()
        {
            DowngradeControls.downgradeButton.Enabled = false;

            DowngradeControls.downgradeButton.Text = "Waiting for login...";
            DowngradeControls.downgradeButton.Refresh();

            login();
 
        }


        private static async void login()
        {
            // Make a new form to show the browser
            Form downgradeMenuLogin = new Form
            {
                Text = "Login",
                Size = new Size(1280, 720),
                StartPosition = FormStartPosition.CenterScreen,
                FormBorderStyle = FormBorderStyle.FixedDialog,
                ShowInTaskbar = false,
                MaximizeBox = false,
            };

            // Get both sso token and etoken for the login process, parse and store then in a JObject
            JObject login_tokens = JObject.Parse(getLoginToken().Result);

            // Set the browser to the Meta login url with the sso etoken we got from the GetLoginToken function
            var browser = new ChromiumWebBrowser($"https://auth.meta.com/native_sso/confirm?native_app_id=512466987071624&native_sso_etoken={login_tokens.GetValue("native_sso_etoken").ToString()}&utm_source=skyline_splash");

            // Add the RequestHandler to allow the browser to handle oculus:// link, pass the UrlCallback function that will be called when an oculus link is detected
            browser.RequestHandler = new OculusProtocolHandler(UrlCallback, login_tokens.GetValue("native_sso_token").ToString());

            // Add the browser form to the downgradeMenuLogin form
            downgradeMenuLogin.Controls.Add(browser);

            // Show the downgradeMenuLogin dialog to open the browser to the Meta login page
            downgradeMenuLogin.ShowDialog();

        }

        private static void UrlCallback(string response, string sso_token)
        {
            var parameters = response.Replace("oculus://", "").Split('?')[1].Split('&');
            var blob = parameters[1].Split('=')[1];
            var token = GetToken(blob, sso_token).GetAwaiter().GetResult();

            Console.WriteLine(token);
            // Working on adding the function to download the build
        }


        private static async Task<string> getLoginToken()
        {
            var payload = new JObject
            {
                { "access_token", "FRL|512466987071624|01d4a1f7fd0682aea7ee8ae987704d63" }
            };

            using (var client = new HttpClient())
            {
                var content = new StringContent(payload.ToString(), Encoding.UTF8, "application/json");
                var response =  client.PostAsync("https://meta.graph.meta.com/webview_tokens_query", content);
                var loginResponse = response.Result.Content.ReadAsStringAsync().Result;
                return loginResponse;
            }
        }

        private static async Task<string> GetToken(string blob, string token)
        {
            var payload = new JObject
            {
                { "access_token", "FRL|512466987071624|01d4a1f7fd0682aea7ee8ae987704d63" },
                { "blob", blob },
                { "request_token", token }
            };

            using (var client = new HttpClient())
            {
                var content = new StringContent(payload.ToString(), Encoding.UTF8, "application/json");
                var response = await client.PostAsync("https://meta.graph.meta.com/webview_blobs_decrypt", content);
                var responseContent = await response.Content.ReadAsStringAsync();
                var jsonResponse = JObject.Parse(responseContent);
                var firstToken = jsonResponse["access_token"].ToString();

                var c = new JObject
                {
                    { "uri", "oculusUri" },
                    { "options", new JObject
                        {
                            { "access_token", string.IsNullOrEmpty(firstToken) ? "OC|752908224809889|" : firstToken },
                            { "doc_id", "5787825127910775" },
                            { "variables", "{\"app_id\":\"1582076955407037\"}" }
                        }
                    }
                };

                content = new StringContent(c["options"].ToString(), Encoding.UTF8, "application/json");
                response = await client.PostAsync("https://meta.graph.meta.com/graphql", content);
                responseContent = await response.Content.ReadAsStringAsync();
                jsonResponse = JObject.Parse(responseContent);

                return jsonResponse["data"]["xfr_create_profile_token"]["profile_tokens"][0]["access_token"].ToString();
            }
        }
    }
}
