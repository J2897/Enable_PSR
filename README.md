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

First, create a **CA** certificate, a **Client** certificate, a **Server** certificate and a **CRL** certificate.

When you choose the 'Import' options in *Enable PSR*, these three files will be expected to exist in the `Certificates` folder:

*	**ca.p7b** - This is the CA certificate which you must create and it is to be imported on both the Client and Server machines.

	Imports to: *Local Computer Account > Trusted Root Certification Authorities*

*	**server.p12** - This is the Server certificate which you must create and it is to be imported on the Server machine(s); each Server requires its own, unique, Server certificate.

	Imports to: *Local Computer Account > Personal*

*	**client.p12** - This is the Client certificate which you must create and it is to be imported on the Client machine only.

	Imports to: *Local Computer Account > Personal*

	***WARNING:*** *The Client certificate contains your Private Key. If you accidentally import it to a Server, your Mum's PC for example, then your Mum may be able to utilise it to hack all of the other Servers that are/were under your control - which would be pretty freaking hilarious!*

You can create your test certificates easily with [XCA] [1]. But you should be aware that, although XCA uses OpenSSL, XCA isn't currently using the latest version of OpenSSL. So if you plan on using PSR over the internet, you should really create your certificates using the latest version of OpenSSL - scroll down for links.

Enable a Client
---------------

1.  Put the **CA** certificate and the **Client** certificate in the `Certificates` folder.

2.  Run `Enable PSR Client.bat` and choose options 1, 2 and 3.

Easy..? You can also launch the MMC by selecting option 4 to verify that your certificates were imported - and if you double-click on your Client certificate, click on the `Details` tab and scroll down, you will see the Thumbprint which you'll need later.

Enable a Server
---------------

1.  Put the **CA** certificate and the **Server** certificate in the `Certificates` folder.

2.  Run `Enable PSR Server.bat` and choose options 1, 2, 3 and 7.

	***NOTE:*** *Option 7 is only necessary if you're using the Windows Firewall.*

If you got an error when you ran option number 3 alerting you that it wasn't possible to automatically create the Listener, you may still be able to create the Listener using option number 4.

MMC (Microsoft Management Console)
----------------------------------

If you want to delete a certificate, or to verify that a certificate has been imported, run **mmc.exe** and do as follows:

1.  Click 'File'.
2.  Click 'Add/Remove Snap-in...'.
3.  Add 'Certificates'.
4.  Select 'Computer account'.
5.  Click 'Next'.
6.  Click 'Finish'.
7.  Click 'OK'.

CRL (Certificate Revocation List)
---------------------------------

After you [Generate a CRL] [2] certificate (crl.der), simply upload it to *any* web-host via FTP.

In your web-host's root folder, create a new folder named **crl** and then upload the **crl.der** file to that folder:

	http://www.example.com/crl/crl.der

*www.example.com* can be any web-address and does not have to be related, nor similar, to any address used for PSR.

The above example URI is also what you should set as the `CRL distribution point` on all of your certificates in XCA.

Connecting to a Server
----------------------

Here's an example of what to type in PowerShell on your Client machine when you're ready to establish a connection with your Server:

	Enter-PSSession -ComputerName "Win7-VM" -CertificateThumbprint "7ed98cd790862135f2d078c783a6e399549a4323" -UseSSL

The Thumbprint should be the Thumbprint of your Client certificate, and the Computer Name should be the Computer Name of the computer you're trying to connect to.

After you have finished playing, be sure to create four new certificates in the latest version of OpenSSL for security reasons.

XCA will allow you to export the [OpenSSL config file] [6] so that you don't have to type out your certificates' information again.

OpenSSL
-------

There are at least two ways to install OpenSSL on Windows:

* [Win32 OpenSSL] [3]
* [Cygwin] [4]

Instructions on how to use OpenSSL:

* [Simple OpenSSL Commands] [5]

   [1]: http://xca.sourceforge.net/xca-14.html#ss14.1
   [2]: http://xca.sourceforge.net/xca.html#toc11
   [3]: http://slproweb.com/products/Win32OpenSSL.html
   [4]: http://robotification.com/2007/08/31/installing-openssl-on-windows/
   [5]: http://datacenteroverlords.com/2012/03/01/creating-your-own-ssl-certificate-authority/
   [6]: http://www.openssl.org/docs/apps/config.html
