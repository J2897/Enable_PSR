Enable_PSR - Beta
=================
*Released under the GNU General Public License version 3 by J2897.*

Enables PowerShell Remoting on Windows 7. First, you will need to create a CA certificate, a Client certificate and a Server certificate.

When you choose the 'Import' options, these three files will be expected to exist in the Certificates folder:

ca.p7b
client.p12
server.p12

You can create your test certificates easily with XCA.
http://xca.sourceforge.net/xca-14.html#ss14.1
