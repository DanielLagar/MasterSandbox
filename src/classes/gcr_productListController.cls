/* 
#    COMPONENT TO SHOW SEARCHED PRODUCT LIST AT GCR WIDGET
#    
#    @param:  NONE
#    @author: ACCENTURE	
#    @date:   26/05/2016
#
*/
public class gcr_productListController {
    // INCOMING VARIABLES FOR THE COMPONENT
    public String strFieldSet { get; set; }
	public String strSobject { get; set; }
    public String strActionJs { get; set; }
    public List<sObject> lProduct { get; set; }
    public Integer desiredResultCount { get; set; }
    public String iconAddRemove { get { return String.isNotEmpty(iconAddRemove) ? iconAddRemove.toUpperCase() : ''; } set; }
    
    // COMPONENT PUBLIC VARIABLES
    public List<Schema.FieldSetMember> lFieldSetMember { get {
        return lFieldSetMember != null && !lFieldSetMember.isEmpty() ? lFieldSetMember
            : Schema.getGlobalDescribe().get(strSobject).getDescribe().fieldSets.getMap().get(strFieldSet).getFields();
    } private set; }
    
    // CONTROLLER CONSTRUCTOR
	public gcr_productListController() {
        
    }
}