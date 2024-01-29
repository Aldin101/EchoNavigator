using Microsoft.Win32;
using System;
using System.Security.Cryptography;
using System.Net.NetworkInformation;
using System.Text.RegularExpressions;
using System.Windows.Forms;
using System.Diagnostics;
using System.Text.Json;

namespace Installer
{
    public static class MenuControls
    {
        public static Label title;
        public static Label username;
        public static TextBox usernameBox;
        public static Label password;
        public static TextBox passwordBox;
        public static PictureBox showPassword;
        public static ToolTip showPasswordTip;
        public static Label textBoxError;
        public static Label disclaimer;
        public static CheckBox disclaimerBox;
        public static Button install;
        public static Button selectGameFolder;
        public static Label currentPath;
        public static Label credits;
    }

    public class ConfigFile
    {
        public string username { get; set; }
        public string password { get; set; }
        public string gamePath { get; set; }
    }

    public static class Global
    {
        public static string gamePath;
    }

    internal static class Program
    {
        public static string FindGameFolder()
        {
            string oculusKeyPath = @"SOFTWARE\Oculus VR, LLC\Oculus\Libraries";
            var oculusKey = Registry.CurrentUser.OpenSubKey(oculusKeyPath);
            if (oculusKey == null)
            {
                return null;
            }

            var locationNames = oculusKey.GetSubKeyNames();
            foreach (var locationName in locationNames)
            {
                var locationKey = oculusKey.OpenSubKey(locationName);
                if (locationKey != null)
                {
                    var originalPath = locationKey.GetValue("OriginalPath") as string;
                    if (originalPath != null)
                    {
                        var gamePath = Path.Combine(originalPath, @"Software\ready-at-dawn-echo-arena\bin\win10\echovr.exe");
                        if (File.Exists(gamePath))
                        {
                            return Path.Combine(originalPath, @"Software\ready-at-dawn-echo-arena");
                        }
                    }
                }
            }

            return null;
        }

        public static void Install()
        {
            if (MenuControls.usernameBox.Text == "" || MenuControls.passwordBox.Text == "")
            {
                MenuControls.textBoxError.Text = "Please enter a username and password";
                return;
            }

            if (MenuControls.passwordBox.Text.Length < 8)
            {
                MenuControls.textBoxError.Text = "Password must be at least 8 characters";
                return;
            }

            if (!Regex.IsMatch(MenuControls.passwordBox.Text, @"[a-zA-Z]"))
            {
                MenuControls.textBoxError.Text = "Password must contain at least one uppercase letter";
                return;
            }

            if (!Regex.IsMatch(MenuControls.passwordBox.Text, @"[0-9]"))
            {
                MenuControls.textBoxError.Text = "Password must contain at least one number";
                return;
            }

            if (Regex.IsMatch(MenuControls.passwordBox.Text, @"[!@#$%^&*()_+=\[{\]};:<>|./?,-]") || Regex.IsMatch(MenuControls.usernameBox.Text, @"[!@#$%^&*()_+=\[{\]};:<>|./?,-]"))
            {
                MenuControls.textBoxError.Text = "Username and Password cannot contain special characters";
                return;
            }

            if (!MenuControls.disclaimerBox.Checked)
            {
                for (int i = 0; i < 3; i++)
                {
                    MenuControls.disclaimer.ForeColor = System.Drawing.Color.Red;
                    MenuControls.disclaimer.Refresh();
                    Thread.Sleep(150);
                    MenuControls.disclaimer.ForeColor = System.Drawing.Color.Black;
                    MenuControls.disclaimer.Refresh();
                    Thread.Sleep(150);
                }
                return;
            }

            if (!(Directory.Exists(Path.Join(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "rad-backup"))))
            {
                Directory.CreateDirectory(Path.Join(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "rad-backup"));
                foreach (var file in Directory.GetFiles(Path.Join(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "rad-backup")))
                {
                    File.Copy(file, Path.Combine(Path.Join(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "rad-backup"), Path.GetFileName(file)), true);
                }
            }


            string hashString;
            using (var sha256 = SHA256.Create())
            {
                using (var stream = File.OpenRead(Path.Combine(Global.gamePath, "bin", "win10", "echovr.exe")))
                {
                    var hash = sha256.ComputeHash(stream);
                    hashString = BitConverter.ToString(hash).Replace("-", "").ToUpper();
                }
            }


            if (hashString != "B6D08277E5846900C81004B64B298DF6ACBA834B69700A640B758BDA94A52043")
            {
                MenuControls.textBoxError.Text = "You are on the wrong version of EchoVR";
                var result = MessageBox.Show("You are on the wrong version of EchoVR, would you like to downgrade?", "Echo Navigator Installer", MessageBoxButtons.YesNo, MessageBoxIcon.Warning);
                if (result == DialogResult.Yes)
                {
                    Downgrader.Downgrade();

                    using (var sha256 = SHA256.Create())
                    {
                        using (var stream = File.OpenRead(Path.Combine(Global.gamePath, "bin", "win10", "echovr.exe")))
                        {
                            var hash = sha256.ComputeHash(stream);
                            hashString = BitConverter.ToString(hash).Replace("-", "").ToUpper();
                        }
                    }

                    if (hashString != "B6D08277E5846900C81004B64B298DF6ACBA834B69700A640B758BDA94A52043")
                    {
                        MessageBox.Show("The game was not downgraded, please try again", "Echo Navigator Installer", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        return;
                    }
                }
                else
                {
                    return;
                }
            }

            if (!Directory.Exists(Path.Join(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "EchoNavigator")))
                Directory.CreateDirectory(Path.Join(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "EchoNavigator"));

            using (StreamWriter file = File.CreateText(Path.Join(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "EchoNavigator", "config.json")))
            {
                var config = new ConfigFile
                {
                    username = MenuControls.usernameBox.Text,
                    password = MenuControls.passwordBox.Text,
                    gamePath = Global.gamePath
                };

                string jsonString = JsonSerializer.Serialize(config);
                file.Write(jsonString);
            }


            using HttpClient client = new HttpClient();
            var response = client.GetAsync("https://aldin101.github.io/EchoNavigatorAPI/EchoNavigator.exe");
            var echoNavigator = response.Result.Content.ReadAsByteArrayAsync();
            File.WriteAllBytes(Path.Join(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "EchoNavigator", "EchoNavigator.exe"), echoNavigator.Result);

            MessageBox.Show("Echo Navigator has been installed", "Echo Navigator Installer", MessageBoxButtons.OK, MessageBoxIcon.Information);

            var startInfo = new ProcessStartInfo
            {
                FileName = Path.Join(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "EchoNavigator", "EchoNavigator.exe"),
            };
            
            Process.Start(startInfo);

            Application.Exit();
        }

        /// <summary>
        ///  The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main(string[] args)
        {
            if (args.Length > 0)
            {
                if (args[0].Contains("oculus://"))
                {
                    File.WriteAllText(Path.Combine(Path.GetTempPath(), "token"), args[0]);
                    Application.Exit();
                }
            }

            Application.EnableVisualStyles();

            Form menu = new Form
            {
                Text = "Echo Navigator Installer",
                //Icon = Properties.Resources.icon,
                Size = new Size(600, 400),
                StartPosition = FormStartPosition.CenterScreen,
                FormBorderStyle = FormBorderStyle.FixedDialog,
                MaximizeBox = false,
            };

            MenuControls.title = new Label
            {
                Text = "Echo Navigator Installer",
                Font = new Font("Arial", 13),
                Location = new Point(10, 8),
                Size = new Size(200, 25),
                TextAlign = ContentAlignment.MiddleLeft,
            };

            MenuControls.username = new Label
            {
                Text = "Username:",
                Font = new Font("Arial", 10),
                Location = new Point(10, 40),
                Size = new Size(200, 20),
            };

            MenuControls.usernameBox = new TextBox
            {
                Font = new Font("Arial", 10),
                Location = new Point(10, 60),
                Size = new Size(200, 20),
            };

            MenuControls.password = new Label
            {
                Text = "Password:",
                Font = new Font("Arial", 10),
                Location = new Point(10, 90),
                Size = new Size(200, 20),
            };

            MenuControls.passwordBox = new TextBox
            {
                Font = new Font("Arial", 10),
                Location = new Point(10, 110),
                Size = new Size(200, 20),
                UseSystemPasswordChar = true,
            };

            MenuControls.showPassword = new PictureBox
            {
                ImageLocation = "https://aldin101.github.io/EchoNavigatorAPI/eye.png",
                Size = new Size(21, 21),
                Location = new Point(188, 111),
                SizeMode = PictureBoxSizeMode.StretchImage,
                Cursor = Cursors.Hand,
            };

            MenuControls.showPasswordTip = new ToolTip
            {
                ToolTipTitle = "Show Password",
                AutomaticDelay = 500,
            };

            MenuControls.textBoxError = new Label
            {
                Text = "",
                Font = new Font("Arial", 8),
                ForeColor = Color.Red,
                Location = new Point(10, 170),
                Size = new Size(210, 20),
            };

            MenuControls.disclaimer = new Label
            {
                Text = "This information is not your Meta log in, it is your account on Echo Relay servers. But your account info is still tied to your Meta account and cannot be changed later. If you forget your account information for a server please contact the server host.\n\nDO NOT use the same password for you Meta account or any other online service. While using unique passwords for all online services is always recommended, it is especially important for Echo Relay because your account information is not secured.",
                Font = new Font("Arial", 10),
                Location = new Point(220, 10),
                Size = new Size(300, 200),
            };

            MenuControls.disclaimerBox = new CheckBox
            {
                Text = "I have read and understand the above notice.",
                Font = new Font("Arial", 10),
                Location = new Point(220, 210),
                Size = new Size(300, 20),
            };

            MenuControls.install = new Button
            {
                Text = "Install",
                Font = new Font("Arial", 10),
                Location = new Point(10, 140),
                Size = new Size(200, 30),
            };
            MenuControls.install.Click += (sender, e) => Install();

            Global.gamePath = FindGameFolder();

            MenuControls.currentPath = new Label
            {
                Text = "Current Game Folder: " + Global.gamePath,
                Font = new Font("Arial", 10),
                Location = new Point(10, 240),
                Size = new Size(2000, 50),
            };

            MenuControls.selectGameFolder = new Button
            {
                Text = "Select Game Folder",
                Font = new Font("Arial", 10),
                Location = new Point(10, 210),
                Size = new Size(200, 30),
            };

            MenuControls.credits = new Label
            {
                Text = "Echo Navigator Created By: Aldin101\nOriginal Echo Relay Created By:Xenomega",
                Font = new Font("Arial", 10),
                Location = new Point(5, 325),
                Size = new Size(300, 50),
            };

            foreach (var field in typeof(MenuControls).GetFields())
            {
                var control = field.GetValue(null) as Control;
                if (control != null)
                {
                    menu.Controls.Add(control);
                }
            }

            menu.ShowDialog();
        }
    }
}