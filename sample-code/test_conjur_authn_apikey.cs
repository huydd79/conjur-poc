using System;
using RestSharp;

namespace TestConjurAuthnAPIKey
{
    class Program
    {
        static String CONJUR_URL = "https://conjur.home.huydo.net";
        static String CONJUR_ACCOUNT = "DEMO";
        static String CONJUR_USER_ID = "testuser01@test";
        static String CONJUR_USER_KEY = "1x1hh0f211c133nzbt6d25v50vrtzyvkm86mzm81h89f392gvexx2";
        static String CONJUR_SECRET_PATH = "test/host1/pass";

        static void Main(string[] args)
        {
            var client = new RestClient();
            var request = new RestRequest(CONJUR_URL + "/authn/" + CONJUR_ACCOUNT + "/" + CONJUR_USER_ID + "/authenticate");
            request.AddHeader("Accept-Encoding", "base64");
            request.AddHeader("Content-Type", "text/plain");
            var body = CONJUR_USER_KEY;
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
