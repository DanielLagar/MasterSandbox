/*
 * @author: Oleg Rikkers
 * @date: 05/13/2014

 * @description: singleton for strike iron service
*/

public with sharing class sf_StrikeIronServiceFactory {

    private static sf_StrikeIronService service;
    
    public static sf_StrikeIronService getStrikeIronService () {
        if (service == null) {
            service = new sf_StrikeIronServiceImpl ();
        }
        
        return service;
    }
}