Enable PSR
==========
*Released under the GNU General Public License version 3 by J2897.*

Enables PSR (PowerShell Remoting) on Windows 7 with HTTPS.

*This has now been successfully tested on 32-Bit Windows 7 (Client) and 64-Bit Windows 7 (Server).*

Prerequisites
-------------

You will need the following beforehand:

* [XCA] [1] - This will create all of your certificates for free.

How to use
----------

First, create a ***CA*** certificate, a ***Client*** certificate, a ***Server*** certificate and a ***CRL*** certificate.

When you choose the 'Import' options in *Enable PSR*, these three files will be expected to exist in the `Certificates` folder:

*	**ca.p7b** - This is the CA certificate which you must create and it is to be imported on both the Client and Server machines.

	Imports to: *Local Computer Account > Trusted Root Certification Authorities*

*	**server.p12** - This is the Server certificate which you must create and it is to be imported on the Server machine(s).

	Imports to: *Local Computer Account > Personal*

*	**client.p12** - This is the Client certificate which you must create and it is to be imported on the Client machine only.

	Imports to: *Local Computer Account > Personal*

	***WARNING:*** *The Client certificate contains your Private Key. If you accidentally import it to a Server, your Mum's PC for example, then your Mum may be able to utilise it to hack all of the other Servers that are/were under your control - which would be pretty freaking hilarious!*

You can create your test certificates easily with [XCA] [1]. But you should be aware that, although XCA uses OpenSSL, XCA isn't currently using the latest version of OpenSSL. So if you plan on using PSR over the internet, you should really create your certificates using the latest version of OpenSSL - scroll down for links.

If you want to delete a certificate, run **mmc.exe** and do as follows:

1.  Click 'File'.
2.  Click 'Add/Remove Snap-in...'.
3.  Add 'Certificates'.
4.  Click 'OK'.
5.  Select 'Computer account'.
6.  Click 'Finish'.

After you [Generate a CRL] [2] certificate (crl.der), simply upload it to *any* web-host via FTP.

In your web-host's root folder, create a new folder named **crl** and then upload the **crl.der** file to that folder:

	http://www.example.com/crl/crl.der

*www.example.com* can be any web-address and does not have to be related, nor similar, to any address used for PSR.

The above example URI is also what you should set as the `CRL distribution point` on all of your certificates in XCA.

Here's an example of what to type in PowerShell on your Client machine when you're ready to establish a connection with your Server:

	Enter-PSSession -ComputerName "Win7-VM" -CertificateThumbprint "7ed98cd790862135f2d078c783a6e399549a4323" -UseSSL

The Thumbprint should be the Thumbprint of your Client certificate.

After you have finished playing, be sure to create four new certificates in the latest version of OpenSSL for security reasons.

XCA will allow you to export the [OpenSSL config file] [6] so that you don't have to type out your certificates' information again.

OpenSSL
-------

There are at least two ways to install OpenSSL on Windows:

* [Win32 OpenSSL] [4]
* [Cygwin] [5]

   [1]: http://xca.sourceforge.net/xca-14.html#ss14.1
   [2]: http://xca.sourceforge.net/xca.html#toc11
   [3]: http://xca.sourceforge.net/xca-9.html#ss9.5
   [4]: http://slproweb.com/products/Win32OpenSSL.html
   [5]: http://robotification.com/2007/08/31/installing-openssl-on-windows/
   [6]: http://www.openssl.org/docs/apps/config.html
