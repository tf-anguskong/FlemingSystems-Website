---
title: "Azure App Service, Web Apps, and Containers"
date: 2020-07-16T21:17:06-07:00
draft: false
tags: ["Business","Learning","Azure"]
description: "How to use Azure App Services and deploy to them"
---

Today my goal was to use docker + Azure to get a web app deployed to Microsoft Azure's web apps. After about 2 hours and some reading I was able to get through it!

It should also be noted that before today I have briefly messed with Docker containers in the past but hadn't quite understood the power of containers. I'm happy to report that I have become a fan! 

---

### Requirements

* Azure Subscription
    * You should be ok with a trial account, but to connect to the Azure shell that it uses in the tutorial you need to spin up a storage account in Azure. 
* GitHub (for the way I went about this)
* Azure App Service
    * This is actually the compute that your web apps (containers) will use. There is a free 30 day basic plan to test this out, but it should be noted that you can scale up and out after creating this. 
* Web App (There is a basic free version that you can run for 30 days.)
    * The individual container(s), you can have multiple web apps on a single app service plan. Resources limited by the Azure App Service.

### Resources

* Used a quick walkthrough from [Microsoft](https://docs.microsoft.com/en-us/learn/modules/deploy-run-container-app-service/1-introduction), this was very easy to use and walkthrough with. They also provide a git rep to clone if you don't have your own repo to pull the docker image from. 
* To refresh myself on the basic of Docker, when I installed docker desktop it actually had a useful tutorial built in! Just install Docker desktop and run through that. 

---

After getting the infrastructure setup in Azure I was able to pull in this [website's git repo](https://github.com/tf-anguskong/FlemingSystems-Website.git) (after adding a dockerfile) directly into a web app contained within the Azure App Service. 

I then created a second app using Docker Compose, which is currently in Preview. I am not familiar with Yaml (it's on my list), so I pulled a wordpress docker-compose.yml from [here](https://docs.docker.com/compose/wordpress/). After uploading the file to Azure and clicking next through the rest of the web app, after 5-10 minutes I had a wordpress site up and running!

What I think is exciting about all of this is that I now understand that web apps in conjunction with an app service plans gives you the infrastructure for simple scalable web applications! It just took me actually going through all of this to get a basic understanding of what Azure App Service + Azure Web Apps are. 

Definitely going to be spending some more time going in depth of the technology.

