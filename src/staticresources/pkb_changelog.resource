## 					JANUARY 2014									 ##

#126 - PKB3: [BUG] Add language paramater to kArticleModel.js

​ 6> PKB does not display translated version of articles on mobile devices.

kArticleModel.js:

20: var req = {
21: searchCriteria: searchQ,
22: lang: '', < missing language parameter
23: dataCategories: '',
24: sessionId: this.sessionId
25: }


change on static resources files:

pkb_mobile/js/views/kArticleDetailView.js

added lang parameter to :
this.model.fetch(lang);

this.model represent object of KArticleModel type

pkb_mobile/js/models/kArticleModel.js
      l = l.replace('l:','');
      searchQ = (this.id != undefined && this.id != '') ? this.id : this.url;
        var req = {
          searchCriteria: searchQ,
          lang : l,
          dataCategories : '',
          sessionId : this.sessionId
        }


## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##

#127 - PKB3: [BUG] Fix issue with the pkb_SecurityHandler class on line 463.
There is an issue with the pkb_SecurityHandler class on line 463.

User u = [ select Id from User
			Where ProfileId IN
				(SELECT Id FROM Profile WHERE Name LIKE '%Admin%' AND UserType = 'Standard') limit 1];
system.runAs(u){

Issue #1: Doesn't have a criteria to make sure the User is Active (causes class to fail!)
Issue #2: Assumes that company has not created profiles with the word "Admin"


Update the query to :

User u = [ select Id from User
			Where ProfileId IN
				(SELECT Id  FROM Profile WHERE name = 'System Administrator' AND UserType = 'Standard')
			 and IsActive = true limit 1];

name of Standard profile can not be edited.


## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
#128 - PKB3: [BUG] Display the first data category only once
3> First data category displayed 2 times

change on static resources files:

pkb_mobile/js/views/filtersbar.js


## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
#147 - PKB3: Generate Sitemap for 1,000 articles at a time (instead of the current 5 at a time)

Sitemap are generated for 5 articles at a time only.
She generate a new page every 5 articles. If you have 10,000 articles, you end up by generating 2,000 sitemap. The target is to have larger batch like 1,000 per sitemap if possible.


the maximum number of articles indexed  will be limited to 2K, due to salesforce standard pagination implementation.  ( The maximum offset is 2,000 rows. Requesting an offset greater than 2,000 will result in a NUMBER_OUTSIDE_VALID_RANGE error.)

current  limit number goes up to  50 articles,end users can update this number


## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
#148 - PKB3: Implement new way to integrate with LiveAgent, in the PKB3 package
1> new way to integrate with LiveAgent

I added a new page : pkb_liveAgentIframe ( needs to be white listed along with other site pages)

The key here would be using a custom event listener within that iframed page to listen when the button becomes available or unavailable and then update the UI chat button on the main page accordingly. Since that button is essentially "static", you can then init only once on that main page after you've filled in the form, etc.


## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
#149 - PKB3: Take Company Business Hours into account when showing/hiding call button

changes on apex class: pkb_mobile_controller
on method getCurrentSiteSetUp

we refactored the logic for displaying/hiding the “Call” btn, previously it only relied on the call channel being enabled and not actually checking the business hours range, this check was done at the end of the contactUs flow.
After the changes the btn will be displayed :
- if call is enabled && now is between business hours.


