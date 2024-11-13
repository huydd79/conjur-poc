######### Skip TLS cert validation
If ("TrustAllCertsPolicy" -as [type]) {} else {
Add-Type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
    ServicePoint srvPoint, X509Certificate certificate,
    WebRequest request, int certificateProblem) {
        return true;
    }
}
"@

[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
}
# Set Tls versions
$allProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $allProtocols
#########

######### Conjur Authentication using API
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Accept-Encoding", "base64")
$headers.Add("Content-Type", "text/plain")

$body = "1r4j3s0fh9pkr24dhrh93hk0d1q38we8cq3tbma19277qbjx1vpw2t4"

$token = Invoke-RestMethod 'https://conjur.home.huydo.net/authn/DEMO/testuser01@test/authenticate' -Method 'POST' -Headers $headers -Body $body


######### Secret request
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Token token=`"$token`"")

$response = Invoke-RestMethod 'https://conjur.home.huydo.net/secrets/DEMO/variable/test/host1/pass' -Method 'GET' -Headers $headers
$response | ConvertTo-Json
