Enable_PSR
==========
*Released under the GNU General Public License version 3 by J2897.*

Enables PSR (PowerShell Remoting) on Windows 7 with HTTPS.

First, you will need to create a CA certificate, a Client certificate, a Server certificate and a CRL certificate.

When you choose the 'Import' options, these three files will be expected to exist in the Certificates folder:

1.  **ca.p7b** (This imports to: *Local Computer Account > Trusted Root Certification Authorities*)
2.  **client.p12** (This imports to: *Local Computer Account > Personal*)
3.  **server.p12** (This imports to: *Local Computer Account > Personal*)

You can create your test certificates easily with [XCA] [1]. *Be aware though that XCA isn't currently using the latest version of OpenSSL!*

If you want to delete a certificate, run **mmc.exe** and do as follows:

1.  Click 'File'.
2.  Click 'Add/Remove Snap-in...'.
3.  Add 'Certificates'.
4.  Click 'OK'.
5.  Select 'Computer account'.
6.  Click 'Finish'.

After you [Generate a CRL] [2] certificate (crl.der), simply upload it to *any* web-host via FTP.

In your web-host's root folder, create a new folder named **crl** and then upload the **crl.der** file to that folder. Example:

	http://www.example.com/crl/crl.der

*www.example.com* can be any web-address and does not have to be related, nor similar, to any address used for PSR!

The above example URI is also what you should set as the `CRL distribution point` on all of your certificates in XCA.

Here's an example of what to type in PowerShell on your Client machine when you're ready to establish a connection with your Server:

	Enter-PSSession -ComputerName "Win7-VM" -CertificateThumbprint "7ed98cd790862135f2d078c783a6e399549a4323" -UseSSL

The Thumbprint should be the Thumbprint of your Client certificate.

After you have finished playing, be sure to create four new certificates in the latest version of OpenSSL for security reasons.

XCA will allow you to export the OpenSSL config file so that you don't have to type out your certicates' information again.

   [1]: http://xca.sourceforge.net/xca-14.html#ss14.1
   [2]: http://xca.sourceforge.net/xca.html#toc11
   [3]: http://xca.sourceforge.net/xca-9.html#ss9.5
