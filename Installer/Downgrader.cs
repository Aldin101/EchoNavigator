using Microsoft.Win32;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Linq;

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

            var registryPath = @"HKEY_CURRENT_USER\SOFTWARE\Classes\oculus";
            var backupPath = Path.Combine(Path.GetTempPath(), "oculus.reg");

            var startInfo = new ProcessStartInfo
            {
                FileName = "reg",
                Arguments = $"export \"{registryPath}\" \"{backupPath}\" /y",
                UseShellExecute = false,
                RedirectStandardOutput = true,
                CreateNoWindow = true
            };

            using (var process = new Process { StartInfo = startInfo })
            {
                process.Start();
                process.WaitForExit();
            }

            try
            {
                Registry.CurrentUser.DeleteSubKeyTree("SOFTWARE\\Classes\\oculus");
            }
            catch{}


            string keyPath = @"Software\Classes\Oculus";
            string fullPath = Process.GetCurrentProcess().MainModule.FileName;
            RegistryKey key = Registry.CurrentUser.CreateSubKey(keyPath);
            if (key != null)
            {
                key.SetValue("URL Protocol", "");
                key.SetValue("", "URL:Oculus Protocol");

                key.CreateSubKey(@"shell\open\command").SetValue("", $"{fullPath} $1");
            } else
            {
                MessageBox.Show("Failed to create registry key");
                return;
            }

            login();
        }

        private static void login()
        {
            var startInfo = new ProcessStartInfo
            {
                FileName = "explorer",
                Arguments = getLoginUrl().Result,
            };

            using (var process = new Process { StartInfo = startInfo })
            {
                process.Start();
            }
        }



        private static async Task<string> getLoginUrl()
        {
            var payload = new JObject
            {
                { "access_token", "FRL|512466987071624|01d4a1f7fd0682aea7ee8ae987704d63" }
            };

            using (var client = new HttpClient())
            {
                var content = new StringContent(payload.ToString(), Encoding.UTF8, "application/json");
                var response = await client.PostAsync("https://meta.graph.meta.com/webview_tokens_query", content);
                var loginResponse = await response.Content.ReadAsStringAsync();
                return loginResponse;
            }
        }

        public static async Task<string> GetToken(string blob, string token)
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

        public static string UriCallback(string response)
        {
            var parameters = response.Replace("oculus://", "").Split('?')[1].Split('&');
            var blob = parameters[1].Split('=')[1];
            var token = GetToken(blob, "token").GetAwaiter().GetResult();

            return token;
        }
    }
}
