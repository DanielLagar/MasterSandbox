/*
Name: sf_getAddressString.resource
*/

function getAddressStringByCountry(addLine1, addLine2, addCity, addState, addZip, country) {
    console.log('***Entered getAddressStringByCountry***');  
    console.log('***country = ***'+country);
    console.log('***addLine1 = ***'+addLine1);
    console.log('***addLine2 = ***'+addLine2);
    console.log('***addCity = ***'+addCity); 
    console.log('***addState = ***'+addState);
    console.log('***addZip = ***'+addZip);
     
    var retVal = '';

    if (country == 'Brazil'){
       
        if (addLine1 != '')
        retVal += addLine1 + '<br/>';
        
		if (addLine2 != '')
		retVal += addLine2 + '<br/>';

		if(addCity != '')
		retVal += addCity + ' ';
		
		if(addState != '')
		retVal += addState;
		
		if(addZip != '')
		retVal += '<br/>' + addZip + '<br/>';
	
		retVal += country;
    }
    
    else if(country == 'Argentina' || country == 'Germany'){
        
        if (addLine1 != '')
        retVal += addLine1 + '<br/>';
        
		if (addLine2 != '')
		retVal += addLine2 + '<br/>';
		
		if(addCity != '')
		retVal += addCity + ' ';
		
		if (addState != '')
		retVal += addState + ' ';
		
		if(addZip != '')
		retVal += addZip;
		
		retVal += '<br/>' + country;
    }
    
    else if (country == 'China'){
       
        if (addLine1 != '')
        retVal += addLine1 + '<br/>';
        
		if (addLine2 != '')
		retVal += addLine2 + '<br/>';
		
		if (addCity != '')
		retVal += addCity + '<br/>';
		
		if(addZip != '')
		retVal += addZip + ' ';
		
		if(addState != '')
		retVal += addState;
		
		retVal += '<br/>' + country;
    }
    
    else if (country == 'Japan'){
        
        if(addZip != '')
		retVal += addZip + '<br/>';
		
		if(addState != '')
		retVal += addState + ' ';
		
		if(addCity != '')
		retVal += addCity;
		
		retVal += '<br/>';
		
		if(addLine1)
        retVal += addLine1 + ' ';

		if(addLine2)
        retVal += addLine2;
		
		retVal += '<br/>' + country;
    }

    else{
        
        if (addLine1 != '')
        retVal += addLine1 + '<br/>';
        
		if (addLine2 != '')
		retVal += addLine2 + '<br/>';
		
		if (addCity != '')
		retVal += addCity + '<br/>';
		
	    if(addState != '')
		retVal += addState + ' ';
		
		if(addZip != '')
		retVal += addZip;
		
		retVal += '<br/>' + country;
    
    }
    
return retVal;
	
} 
    