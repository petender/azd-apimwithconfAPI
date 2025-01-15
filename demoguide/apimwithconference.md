[comment]: <> (please keep all comment items at the top of the markdown file)
[comment]: <> (please do not change the ***, as well as <div> placeholders for Note and Tip layout)
[comment]: <> (please keep the ### 1. and 2. titles as is for consistency across all demoguides)
[comment]: <> (section 1 provides a bullet list of resources + clarifying screenshots of the key resources details)
[comment]: <> (section 2 provides summarized step-by-step instructions on what to demo)


[comment]: <> (this is the section for the Note: item; please do not make any changes here)
***
### Azure API Management with Conference demo API - demo scenario

<div style="background: lightgreen; 
            font-size: 14px; 
            color: black;
            padding: 5px; 
            border: 1px solid lightgray; 
            margin: 5px;">

**Note:** Below demo steps should be used **as a guideline** for doing your own demos. Please consider contributing to add additional demo steps.
</div>

[comment]: <> (this is the section for the Tip: item; consider adding a Tip, or remove the section between <div> and </div> if there is no tip)

<div style="background: lightblue; 
            font-size: 14px; 
            color: black;
            padding: 5px; 
            border: 1px solid lightgray; 
            margin: 5px;">

**Tip:** The scenario is based on the Microsoft Learn tutorial on Azure API Management using the Conference Demo API (https://learn.microsoft.com/en-us/azure/api-management/import-and-publish), but it still allows adding your own custom API scenario to the deployed resource. 
</div>

<div style="background: lightgreen; 
            font-size: 14px; 
            color: black;
            padding: 5px; 
            border: 1px solid lightgray; 
            margin: 5px;">

**Note:** Before deleting the Resource Group and/or API Management Gateway, take note of the **API Management Resource name and region**, as this information is required to **purge** the Resource after deleting it. If the resource is not purged, **you cannot** redeploy the scenario.- For the purge process, see all the way at the end of the demoguide.
</div>

***
### 1. What Resources are getting deployed
This scenario deploys the sample **Conference Demo API** as a running **Azure API Management published API**. 

* MTTDemoDeployRGc%youralias%APIM - Azure Resource Group.
* %youralias%demoapim - Azure API Management Resource
* MTT Demo Conference API - published API, connecting to the sample https://conferenceapi.azurewebsites.net 

<img src="./APIM/ResourceGroup_Overview.png" alt="APIM Resource Group" style="width:70%;">
<br></br>

<img src="./APIM/demoapi_overview.png" alt="Demo API Management Service" style="width:70%;">
<br></br>

<img src="./APIM/conference_demo_api.png" alt="Conference Demo API" style="width:70%;">
<br></br>

### 2. What can I demo from this scenario after deployment
### API Management Published APIs

1. Navigate to the **deployed API Management Resource** blade. 
2. Show the **main information** related to the resource, by navigating through the **Overview** blade.
- Gateway URL: the URL listener from the API Management gateway; this would be the URL to use in your front-end application
- Virtual IP address: while not used for the service connectivity, it could be useful if the API Management Service is running behind a firewall
- Pricing Tier: API Management provides 4 different tiers (Developer, Standard, Premium, Consumption); the demo is deployed using **Standard**, as a single unit of scale
- APIs: we have 2 API endpoints published
- Subscriptions: there are 4 subscriptions offered by the gateway

3. Navigate to **APIs** and select **APIs**. This shows you 2 different published APIs, 
- Echo API: sample API which returns basic information when connecting to it.
- MTT Demo Conference API: simulates a published API with different API endpoints for pulling up Conference information such as speaker(s), session(s),... this is the main API to use in the demo scenarios below. 

<img src="./APIM/published_APIs.png" alt="2 Published APIs for demos" style="width:70%;">
<br></br>

4. Navigate to **MTT Demo Conference API**
5. From the **Design** tab, notice the different API operations available (GetSession(s), GetSpeaker(s), GetTopic(s))

<img src="./APIM/API_operations.png" alt="API Operations" style="width:70%;">
<br></br>

6. Navigate to the **Test** tab
7. Select the **GetSessions** API 


<img src="./APIM/Get_Sessions.png" alt="GetSessions API Operation" style="width:70%;">
<br></br>

8. Press the **Send** button
9. Scroll down in the body section to HTTP Response, and show the **JSON** output from the Get Operation

<img src="./APIM/Get_Sessions_HTTPResponse.png" alt="GetSessions API Operation HTTP Response" style="width:70%;">
<br></br>

### API Management Inbound and Outbound Processing Policies
1. **Emphasize** some of the **Header** information that is getting exposed:
- x-aspnet-version
- x-powered-by

and hightlight this could be a security risk (you are telling what platform the API is running in the backend, which could be targeted for vulnerabilities now)

<img src="./APIM/Get_Sessions_Headers.png" alt="GetSessions API Operation Header" style="width:70%;">
<br></br>

2. The **solution** for the security risk, is using **APIM Outbound Processing Policies**, which is configured for the **GetSpeakers** API. 

3. Navigate to the **GetSpeakers** API, and zoom in on the **Outbound Processing**. Notice the **set-header** policy items.

<img src="./APIM/Get_Speakers_Outbound.png" alt="GetSpeakers Outbound Processing" style="width:70%;">
<br></br>

4. **Click** the **set-header** policy. This opens the XML-details of the Outbound Processing Policy for this API

<img src="./APIM/Get_Speakers_Outbound_Policy.png" alt="GetSpeakers Outbound Processing Policy" style="width:70%;">
<br></br>

5. Another common use case for API Gateways, is **limiting the number of requests** an API should/can handle. This can be managed using **Inbound Policies**. 

6. From the **GetSpeakers** API, zoom in on the **Inbound Processing** from the **Design** tab.
7. Notice the **rate-limit-by-key** policy setting. Click the **...** next to it. Select **Form-based Editor**.

<img src="./APIM/Get_Speakers_Policy_formeditor.png" alt="GetSpeakers Inbound Processing Policy" style="width:70%;">
<br></br>

8. This allows you to define Policy settings using the Graphical editor, instead of the XML syntax

<img src="./APIM/Get_Speakers_Policy_formeditor_details.png" alt="GetSpeakers Inbound Processing Policy" style="width:70%;">
<br></br>

9. To simulate the **rate limits**, navigate back to **GetSpeakers**, and select the **Test** tab; Press the **Send** button to retrieve the JSON response for this API.

<img src="./APIM/Get_Speakers_Response.png" alt="GetSpeakers JSON Response" style="width:70%;">
<br></br>

10. **Repeat** this process by clicking the **Send** button more than 1 times within 30 seconds. this will result in a **Rate Limit Exceeded** Response

<img src="./APIM/Get_Speakers_TooManyRequests.png" alt="GetSpeakers Rate Limit Exceeded" style="width:70%;">
<br></br>

11. After the time limit has passed, pressing **Send** again, will provide the expected JSON response with Speaker details.

### API Management Products and Subscriptions
1. Typically, you want to limit access to the API Management published APIs. This can be done using **Products** and **Subscriptions**. 

2. From the API Management Blade, navigate to **Products**. 

<img src="./APIM/Products.png" alt="API Management Products" style="width:70%;">
<br></br>

3. Notice the **mtt_custom** Product currently only allows **Administrators** to use it. This is perfect for testing by your developers, before publicly exposing the actual API endpoints. 

4. Open the **mtt_custom** Product by clicking on its name. this opens the Product blade.

<img src="./APIM/Products_details.png" alt="API Management Products details" style="width:70%;">
<br></br>

5. Select **APIs**, which shows more details about which API is linked to this Product. 

6. Select **Subscriptions**, which shows the API Primary and Secondary key your developers would use in order to interact with this Product.  

<img src="./APIM/Products_Subscriptions.png" alt="API Management Products Subscriptions details" style="width:70%;">
<br></br>

## Properly Deleting your API Management Gateway 

When you delete the Resource Group or the API Management Gateway Resource, it is only **soft-deleted**. This will block you from redeploying the same API Management Gateway. 

In order to succeed in a redeployment after soft-delete, a **purge** operation is required. this can be done using **Azure Cloud Shell**

1. Open **Azure Cloud Shell** and select **Bash**
2. Run the following Azure CLI command to **get a list of API Management resources in soft-delete state**:

```
az rest --method GET --url https://management.azure.com/subscriptions/<yoursubscriptionidhere>/providers/Microsoft.ApiManagement/deletedservices?api-version=2021-08-01
```
3. Take note of the location and API Management resource name, as you need it in the next command.

4. Run the following Azure CLI Command to **trigger the delete action**:

```
az rest --method delete --url https://management.azure.com/subscriptions/<yoursubscriptionidhere>/providers/Microsoft.ApiManagement/locations/eastus/deletedservices/petenderdemoapim?api-version=2021-08-01
```

You can now run the scenario deployment again.

[comment]: <> (this is the closing section of the demo steps. Please do not change anything here to keep the layout consistant with the other demoguides.)
<br></br>
***
<div style="background: lightgray; 
            font-size: 14px; 
            color: black;
            padding: 5px; 
            border: 1px solid lightgray; 
            margin: 5px;">

**Note:** This is the end of the current demo guide instructions.
</div>




