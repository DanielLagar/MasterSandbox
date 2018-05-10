/*
* @author: Oleg Rikkers
* @date: 07/10/2014
* @description:  Extension class for Case highlight panel page
*/

public with sharing class sf_CaseHighlightsPanelExt {

	public String timeOpened {get; private set;}
	public String brands;
	public String products;
	public String comments;
	public Boolean showMakeMeCaseOwner {get; set;}

	private Case c;
	private List <Case_Product__c> caseProducts;

	public sf_CaseHighlightsPanelExt(ApexPages.StandardController sc) {
		c = (Case) sc.getRecord();
		showMakeMeCaseOwner = c.OwnerId == null ? false : String.valueOf(c.OwnerId.getSobjectType()) != 'User';

		if (c.Received_Date__c != null) 
			timeOpened = c.Received_Date__c.format('hh:mm a', String.valueOf(UserInfo.getTimeZone()));
		
		caseProducts = new List <Case_Product__c> ([SELECT Id
										,Local_Product__r.Global_Product__r.Brand__c
										,Local_Product__r.Name
									FROM Case_Product__c 
									WHERE Case__c = :c.Id]);


	}

	public String getBrands () {
		brands = '';
		Set <String> bSet = new Set <String> ();
		

		for (Case_Product__c cp: caseProducts) {
			if (cp.Local_Product__r.Global_Product__r.Brand__c != null)
				bSet.add (cp.Local_Product__r.Global_Product__r.Brand__c);
		}

		for (String s: bSet) {
			brands += ' ' + s + ',';
		}

		return brands.removeEnd(',');
	}


	//ALM276 - remove products

	//public String getProducts () {
	//	products = '';
	//	Set <String> pSet = new Set <String> ();
		

	//	for (Case_Product__c cp: caseProducts) {
	//		pSet.add (cp.Local_Product__r.Name);
	//	}

	//	List <String> pList = new List <String> ();

	//	pList.addAll(pSet);

	//	String s = '';

	//	for (Integer i=0; i<pList.size(); i++) {
	//		if (i==2) {
	//			s += ' +' + String.valueOf(pList.size()-2) + ' more...';
	//			break;
	//		} else {
	//			s += ' ' + pList[i] + ',';
	//		}
	//	}

	//	products = s.removeEnd(',');

	//	return products;
	//}

	public String getComments () {
		Set <String> cSet = new Set <String> ();

		for (Case_Comment_Code__c ccc: [SELECT Id
											,Local_Comment_Code__r.Level_3__c 
										FROM Case_Comment_Code__c 
										WHERE Case__c = :c.Id]) {
			cSet.add (ccc.Local_Comment_Code__r.Level_3__c);
		}

		List <String> cccList = new List <String> ();

		cccList.addAll(cSet);
		String s = '';

		for (Integer i=0; i<cccList.size(); i++) {
			if (i==2) {
				s += ' +' + String.valueOf(cccList.size()-2) + ' more...';
				break;
			} else {
				s += ' ' + cccList[i] + ',';
			}
		}

		comments = s.removeEnd(',');
		return comments;
	}
}