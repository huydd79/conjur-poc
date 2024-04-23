using System;
using System.IO;
using RestSharp;


namespace TestConjurAuthnJWT
{
    class Program
    {
        static String CONJUR_URL = "https://conjur.home.huydo.net";
        static String CONJUR_ACCOUNT = "DEMO";
        static String CONJUR_SECRET_PATH = "test/host1/pass";

        static String JWT_SERVICE_ID = "testjwt";
        static String JWT_FILE = "C:\\cybr\\test.jwt";

        static void Main(string[] args)
        {
            var client = new RestClient();
            var request = new RestRequest(CONJUR_URL + "/authn-jwt/" + JWT_SERVICE_ID + "/" + CONJUR_ACCOUNT + "/authenticate");
            request.AddHeader("Accept-Encoding", "base64");
            request.AddHeader("Content-Type", "text/plain");
            var JWT = "";
            if (!File.Exists(JWT_FILE))
            {
                Console.WriteLine("JWT file " + JWT_FILE + " is not found!!!");
                Console.ReadLine();
                return;
            }
            else
            {
                JWT = File.ReadAllText(JWT_FILE);
            }

            var body = "jwt=" + JWT;
            request.AddParameter("text/plain", body, ParameterType.RequestBody);
            var response = client.Post(request);

            Console.WriteLine("Auth request result: " + (int)response.StatusCode + " " + response.StatusCode);

            if ((int)response.StatusCode != 200)
            {
                Console.WriteLine("Authentication failed. Press any key to exit...");
                Console.ReadLine();
                return;
            }
            var TOKEN = response.Content;
            Console.WriteLine("TOKEN: " + TOKEN);

            request = new RestRequest(CONJUR_URL + "/secrets/" + CONJUR_ACCOUNT + "/variable/" + CONJUR_SECRET_PATH);
            request.AddHeader("Accept-Encoding", "base64");
            request.AddHeader("Content-Type", "text/plain");
            request.AddHeader("Authorization", "Token token=\"" + TOKEN + "\"");
            response = client.Get(request);

            Console.WriteLine("Result: " + (int)response.StatusCode + " " + response.StatusCode);
            Console.WriteLine("Secret request result: " + (int)response.StatusCode + " " + response.StatusCode);

            Console.WriteLine("Secret: " + response.Content);
            Console.WriteLine("Press any key to exit...");
            Console.ReadLine();
        }
    }
}
