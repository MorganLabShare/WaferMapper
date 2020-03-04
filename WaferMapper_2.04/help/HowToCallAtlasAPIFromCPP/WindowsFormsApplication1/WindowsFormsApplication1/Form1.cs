using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace WindowsFormsApplication1
{
    public partial class Form1 : Form
    {
        NPVE3Z.IFibicsSEMVE veobj;
        public Form1()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            try
            {
                veobj = new NPVE3Z.FibicsSEMVE();
                button2.Enabled = true;
                button1.Enabled = false;
            }
            catch (Exception ex)
            {
                MessageBox.Show("Fibics SEM-VE Object creation failed: " +
                                ex.Message);
            }

        }

        private void button2_Click(object sender, EventArgs e)
        {
            try
            {
                veobj.AcquireImage(1024, 1024, 1.0f, "C:\\SEMUsers\\ATLASAPITest.tif");
                while (veobj.Busy)
                    System.Threading.Thread.Sleep(20);
                MessageBox.Show("Image complete");
            }
            catch (Exception ex)
            {
                MessageBox.Show("Image acquisition failed: " + ex.Message);
            }

        }
    }
}
