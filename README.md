Enable_PSR
==========
*Released under the GNU General Public License version 3 by J2897.*

Enables PowerShell Remoting on Windows 7 with HTTPS.

First, you will need to create a CA certificate, a Client certificate and a Server certificate.

When you choose the 'Import' options, these three files will be expected to exist in the Certificates folder:

1.  **ca.p7b**
2.  **client.p12**
3.  **server.p12**

You can create your test certificates easily with [XCA] [1].

Be aware though that [XCA] [1] isn't currently using the latest version of OpenSSL.

Here's an example of what to type in PowerShell on your Client machine when you're ready to establish a connection with your Server:

		Enter-PSSession -ComputerName "Win7-VM" -CertificateThumbprint "7ed98cd790862135f2d078c783a6e399549a4323" -UseSSL

After you have finished playing, be sure to create three new certificates in the latest version of OpenSSL for security reasons.

[XCA] [1] will allow you to export the OpenSSL config file so that you don't have to type out your certicate's information again.

   [1]: http://xca.sourceforge.net/xca-14.html#ss14.1
