package com.android.todo4group.services;

import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.JsonHttpResponseHandler;
import com.loopj.android.http.RequestParams;

/**
 * Created by paulyang on 12/30/16.
 */
public class HttpClientWrapperForFCM {

    AsyncHttpClient client = new AsyncHttpClient();
    String registerUrl = "http://appname.herokuapp.com/register";  // don't need -d
    String sendUrl = "http://appname.herokuapp.com/send";
    RequestParams params;

    public HttpClientWrapperForFCM() {

    }

//    curl http://appname.herokuapp.com/register -d "reg_token=your-token&user_id=receiveruserid"
    public void registerFirebaseToken(String fbToken, String user_id) {
        params = new RequestParams();

        params.put("reg_token", fbToken);
        params.put("user_id", user_id);

        sendClientCall(registerUrl, params);
    }

    // curl http://appname.herokuapp.com/send -d "user_id=receiveruserid&title=hello&body=message to mjpablo23"
    public void sendMessage(String uid, String title, String message) {
        params = new RequestParams();
//        String user_id = "receiveruserid";
        params.put("user_id", uid);
        params.put("title", title);
        params.put("body", message);

        sendClientCall(sendUrl, params);
    }

    public void sendClientCall(String url, RequestParams params) {
        // network request.  url request.  response handle is the json http response handler

        client.post(url, params, new JsonHttpResponseHandler() {
            // haven't printed the response, check for errors?
        });
    }

}
