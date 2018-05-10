global class InternalActivityUtility
{
    webservice static Integer CloseActivity(List<String> activityIds)
    {
        try
        {
            List<Internal_Activity__c> alist=new List<Internal_Activity__c>();
            for(String s:activityIds)
            {
                 Internal_activity__c ia=new Internal_Activity__c(id=s);
                 ia.Status__c='Closed';
                 alist.add(ia);   
            }
            update alist;
            return 1;
        }
        catch(Exception e)
        {
            return 0;
        }
    }
}