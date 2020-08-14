---
title: "Disabling Self-Service Purchasing"
date: 2020-08-14T13:29:44-07:00
draft: false
tags: ["Microsoft 365","Best Practice"]
description: "Disabling the ability for individual users to purchase licensing for a companies Microsoft 365 tenant"
---

### Just another way for Microsoft to get more money, rediculous

Microsoft will be releasing the "feature" soon that will allow individual users to purchase certain licensing SKUs themselves through their work accounts. When they attempt to purchase these licenses it will ask for their credit card information, so it won't add a bill to your corporate Microsoft invoice but instead allows the potential for unwanted licenses being purchased. 

There are a lot of reason why this could be an issue, but just to name a few:
* Individual's don't understand the SKU differences, especially when it comes to certain SKUs like Power Apps.
* The ever lasting issue of, "we bought this, now can you support it?" that comes from shadow IT purchases. 

At the time of this writing these are the SKUs that appear to be available for purchasing:
 * Microsoft Project Plans 1 and 3
 * Microsoft Visio Plan 1 and 2
 * Power Apps
 * Power BI Pro
 * Power Automate

If you run the script below it will disable the ability for an individual to purchase licensing themselves; granted admin will be notified via email for a request of the license.... it's better than nothing! For anyone that isn't familiar with powershell I'll detail this a little further below as powershell is the ONLY way to disable this feature and I believe that not everyone should have to know powershell to administrate something as simple as this.

```powershell
#Install Module from PSGallery
Install-Module -Name MSCommerce

#Connect 
Connect-MSCommerce

#Get Policy ID
$PolicyID = (Get-MSCommercePolicies).PolicyID

#Get all Product Policies
$Products = Get-MSCommerceProductPolicies -PolicyId $PolicyID

#Disable Self Service Purchase for each Product
foreach ($P in $Products){

    Update-MSCommerceProductPolicy -PolicyId $PolicyID -ProductId $P.ProductID -Enabled $False

}

#Sanity Check
 Get-MSCommerceProductPolicies -PolicyId $PolicyID
 ```
---
# Detailed Instructions 
1. Open a powershell window as administrator.
2. Run the first line ```Install-Module -Name MScommerce```, this will install the MSCommerce module from PSGallery, answer Y or A to the prompt.
3. Once the module is installed run the ```Connect-MSCommerce``` command, this will open a window prompting for your Microsoft 365 credentials. 
4. Once connected you can copy and paste the rest of the script, which will disable this Self Service Purchasing Ability. 
```powershell
#Get Policy ID
$PolicyID = (Get-MSCommercePolicies).PolicyID

#Get all Product Policies
$Products = Get-MSCommerceProductPolicies -PolicyId $PolicyID

#Disable Self Service Purchase for each Product
foreach ($P in $Products){

    Update-MSCommerceProductPolicy -PolicyId $PolicyID -ProductId $P.ProductID -Enabled $False

}

#Sanity Check
 Get-MSCommerceProductPolicies -PolicyId $PolicyID
```
5. The last line will return all the list of ProductIDs and under the Policy Value column you should see Disabled. 

That's it! Simple, unfortunately at the time of this writing this is the ONLY way to disable the Self Service Purchasing.

Good luck out there everyone, hopefully someone can benefit from this before this "feature" bites them in the butt. 