@isTest
public class SFPS_GNC_GetNextCaseTest
{
    static testMethod void SFPS_GNC_GetNextCaseTest()
    {
        //Setup g1 queue group
        Group g1 = new Group();
        g1.type = 'Queue';
        g1.name = 'Test group 1';
        insert g1;

        //Setup g2 queue group
        Group g2 = new Group();
        g2.type = 'Queue';
        g2.name = 'Test group 2';
        insert g2;

        //Setup g3 public group
        Group g3 = new Group();
        g3.type = 'Regular';
        g3.name = 'Test group 3';
        insert g3;

        //Setup user as member of g1 queue
        Groupmember gm1 = new GroupMember();
        gm1.userorgroupid = userinfo.getUserId();
        gm1.groupid = g1.id;
        insert gm1;

        //Setup g3 group as member of g2 queue
        Groupmember gm2 = new GroupMember();
        gm2.userorgroupid = g3.Id;
        gm2.groupid = g2.id;
        insert gm2;

        //Setup user as member of g3 group, which is a member of g2 queue
        Groupmember gm3 = new GroupMember();
        gm3.userorgroupid = userinfo.getUserId();
        gm3.groupid = g3.id;
        insert gm3;

        //Setup g1 queue 
        QueueSobject q1 = new QueueSobject();
        q1.queue = g1;
        q1.queueId  = g1.id;
        q1.sobjectType = 'Case';
        insert q1;

        //Setup g2 queue 
        QueueSobject q2 = new QueueSobject();
        q2.queue = g2;
        q2.queueId  = g2.id;
        q2.sobjectType = 'Case';
        insert q2;

        User usr = [Select id from User where Id = :UserInfo.getUserId()];

        System.RunAs(usr)
        {
            //Create case with GNC priority date order in c1, c3, c2
            Case c1 = new Case();
            c1.ownerid = g1.Id;
            c1.subject = 'c1';
            c1.Priority = '1';
            //c1.SFPS_GNC_PriorityDate__c = DateTime.parse('10/7/2015 12:00 AM');
            insert c1;

            Case c2 = new Case();
            c2.ownerid = g1.Id;
            c2.subject = 'c2';
            c2.Priority = '3';
            //c2.SFPS_GNC_PriorityDate__c = DateTime.parse('12/7/2015 12:00 AM');
            insert c2;

            Case c3 = new Case();
            c3.ownerid = g2.Id;
            c3.subject = 'c3';  
            c2.Priority = '2';         
            //c3.SFPS_GNC_PriorityDate__c = DateTime.parse('11/7/2015 12:00 AM');
            insert c3;

            Test.startTest();

            SFPS_GNC_GetNextCase gnc;

            //Verify the first case pulled back is c1
            //from g1 queue, where user is a direct member of
            gnc = new SFPS_GNC_GetNextCase();   
            gnc.AssignNextRecord();
            Case c1x = [Select Id, Ownerid from Case Where id = :c1.Id];            
            //system.assertEquals(usr.Id,c1x.OwnerId);

            //Verify the second case pulled back is c3
            //from g2 queue where user is only a member of a public group, which is a member of the g2 queue
            gnc = new SFPS_GNC_GetNextCase();       
            gnc.AssignNextRecord();
            Case c3x = [Select Id, Ownerid from Case Where id = :c3.Id];
            //system.assertEquals(usr.Id,c3x.OwnerId);     

            //Verify the third case pulled back is c2, which has lower priority than c3, based on GNC priority date
            gnc = new SFPS_GNC_GetNextCase();            
            gnc.AssignNextRecord();
            Case c2x = [Select Id, Ownerid from Case Where id = :c2.Id];
            //system.assertEquals(usr.Id,c2x.OwnerId);
            
            Test.stopTest();
        }
    }
}