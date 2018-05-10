    input, select, textarea {
          box-sizing: border-box;
          -ms-box-sizing:border-box;
          -moz-box-sizing: border-box;
          -webkit-box-sizing: border-box;
    }
    .sectionExistingContacts{
        margin: 10px 0px;
        border-collapse: separate;
        border-width: 1px;
        border-color: rgb(198,204,206);
        border-style: solid;
        border-radius: 4px;
        border-spacing: 0px;
        cellpadding: 0px;
        background-color: #F7F7F7;
        border-top: thick solid #1D71C7;
    }
    .section{
        margin: 10px 0px;
        border-collapse: separate;
        border-width: 1px;
        border-color: rgb(198,204,206);
        border-style: solid;
        border-radius: 4px;
        border-spacing: 0px;
        cellpadding: 0px;
        background-color: #F7F7F7;
    }

    .sectionHeader{
        margin-top: 10px;
        margin-left: 10px;
        color: #000000;
                
        font-size: 20pt;
        font-family: "Arial";
        font-style: normal;
        text-align: left;
        
        line-height: 12pt;
        letter-spacing: 0em;
    }
    
    .subSectionHeader{
        color: #000000;
        font-size: 13pt;
        font-family: "Arial";
        font-style: normal;
        text-align: left;
        font-weight: bold;
        line-height: 16pt;
        letter-spacing: 0em;
        
        float:left;
        position:absolute;
        overflow:hidden;
        z-index: 10;
    }
    
    .existingContactHeader{
        overflow:hidden;
        text-align: center;
        width: 100%;
    }
    
    .insideSection{
        border-width: 1px;
        border-color: rgb(198,204,206);
        border-style: solid;
        border-radius: 4px;
        background-color: #FFFFFF;
        margin: 13px 10px 10px;
        padding: 20px 30px 2px 18px;
    }
    
    .addressPanel{
        margin: 10px 0px;
    }
    
    .addressPanelInsideSection{
        border-width: 1px;
        border-color: rgb(198,204,206);
        border-style: solid;
        background-color: #FFFFFF;
        padding: 20px 30px 2px 18px;
    }
    
    .addressContainer{
        border-radius: 4px;
    }
    
    .sectionFields{
        width: 197px;
    }
    
    .firstColumnAddressField{
        width: 138px;
    }
    
    .lookupClass{
        width: 55px;
    }
    
    .savebtn{
        float: right;
        width: 100px;
        max-width: 100%;
        max-heigth: 100%;
        
        display: inline-block;
        vertical-align: middle;
    }
    
    .existContactSection {
        margin: 10px;
        text-align: center;
    }
    
    .existContactbtn {
        background: #1D71C7 !important;
        color : #FFFFFF !important;
        width: 140px;
    }
    
    .icons{
        float: right;
    }
    
    .showAddressIcon{
        margin: 3px 2px 2px 6px; 
    }
    
    .hideAddressIcon{
        display: none;
    }
    
    .topButtonSection{
        overflow: auto;
        padding-top: 10px;
    }
    
    .bottomButtonSection{
        overflow: auto;        
        padding-bottom: 10px;
    }
    
    .activeTab {
        color: #FFFFFF;
        background-color: #1D71C7;  
        font-weight: bold;  
        background-image:none;
    }
    
    .inactiveTab { 
        color: #000000;
        background-color: #FAF9F6; 
        font-weight: bold; 
        background-image:none;
    }
    
    .tabContent {
        background-color: #F7F7F7;
        border-radius: 4px;
    }

    .verifyAddress{
        padding: 8px 10px;
        background-color: #C6CCCE;
        border-bottom-left-radius: 3px;
        border-bottom-right-radius: 3px;
    }
    
    .phoneField{
    
    }
    
    .verifiedField{
        color: #386EC6;
    }
    
    .unverifiedField{
        color: #000000;
    }
    
    .phoneField:before{
        content:url("{!URLFOR($Resource.sf_ContactInfoValidAddress)}");
        opacity: 0.5;
        padding-right: 4px;
    }
    
    .invalidField{
        background-color: #FFDBDB;
        border: 2px solid #AF1914;
    }
    
    .validField{
        border: 2px solid #6dc422;
    }
    
    .invalidFieldText{
        color-family: Arial-BoldMT;
        font-size: 10pt;
        color: #AF1914;
    }
    
    .validIcon{
        vertical-align: middle;
    }
    
    .bottomPanel{
        background-color: #C6CCCE;
        width: 100%;
        height: 35px;
        overflow: auto;
        display: table;
        border-bottom-radius: 3px;
    }
    
    .topPanel{
        border-top-right-radius: 4px;
        border-top-left-radius: 4px;
    }
    .button-wrapper {
        border: none;
        display: table-cell;
        vertical-align: middle;
        padding: 8px 10px;
    }
    
    .hideLineSeparator{
        border:0px;
    }
    
    .mainContainer{
        width: 99%;
        margin: 5px;
        border-width: 1px;
        border-color: #666666;
        border-style: solid;
        padding-left: 5px;
        padding-right: 5px;
        /*background: #f8f8f8;*/
    }
    
    .savedTime{
        float: right;
        margin-top: 5px;
        margin-right: 5px;
        color: green;
    }
    th.labelCol, td.dataCol{
        border: 0px !important;
    }

    tr.dataRow th, tr.dataRow td {
        border-width: 0 0 1px 1px !important;
    }