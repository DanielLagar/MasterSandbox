    @import url(//maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css);

    /*Start Site Font Styles*/
    body {
        font-family: “Myriad Pro”, Arial, Helvetica, sans-serif;
        margin: 0px;
    }
    /*End Site Font Styles*/
    
    /* BUTTON STYLING CSS CLASS */
    .btnStyling {
        border:none;
        background-color: black;
        color: white;
        -webkit-appearance: none;
        -webkit-border-radius: 0;
        font-size: 1em;
        cursor: pointer;
        background:-webkit-gradient(linear, left top, left bottom, color-stop(0.05, #ababab), color-stop(1, #090e14));
        background:-moz-linear-gradient(top, #ababab 5%, #090e14 100%);
        background:-webkit-linear-gradient(top, #ababab 5%, #090e14 100%);
        background:-o-linear-gradient(top, #ababab 5%, #090e14 100%);
        background:-ms-linear-gradient(top, #ababab 5%, #090e14 100%);
        background:linear-gradient(to bottom, #ababab 5%, #090e14 100%);
        filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='#ababab', endColorstr='#090e14',GradientType=0);
        background-color:#ababab;
        -moz-border-radius:1px;
        -webkit-border-radius:1px;
        border-radius:1px;
        border:1px solid #1c1f1b;
    }
    .btnStyling:hover {
        background:-webkit-gradient(linear, left top, left bottom, color-stop(0.05, #090e14), color-stop(1, #ababab));
        background:-moz-linear-gradient(top, #090e14 5%, #ababab 100%);
        background:-webkit-linear-gradient(top, #090e14 5%, #ababab 100%);
        background:-o-linear-gradient(top, #090e14 5%, #ababab 100%);
        background:-ms-linear-gradient(top, #090e14 5%, #ababab 100%);
        background:linear-gradient(to bottom, #090e14 5%, #ababab 100%);
        filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='#090e14', endColorstr='#ababab',GradientType=0);
        background-color:#090e14;
    }
    .attachedFilesPanelContainer {
        margin-top: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
    } 
    .attachedFile {
        margin-top: 5px;
        outline: 1px solid #DDDDDD;
        background: #FFF;
        width: 100%;
        text-align: center;
        margin-bottom: 5px;
        height:25px;
        display: flex;
    }
    .attachedFileText {
        width: calc(100% - 27px);
        text-align: left;
        display: inline-flex;
        font-size: 0.85em;
        margin-left: 8px;
        height: inherit;
        align-items: center;
        overflow: hidden;
    }   
    .attachedFileRemoveIcon {
        display: inline-flex;
        justify-content: center;
        align-items: center;
        height: 25px;
        width: 25px;
    }
    .attachedFilesLabel {
        text-align: center;
    }
    .inputFileEnable {
        width: 130px;
        height: 25px;
        background-color: black;
        color: white;
        margin-left: auto;
        margin-right: auto;
        cursor: pointer;
        position: relative;
        overflow: hidden;
    }
    .fileUpload {
        display: inline-block;
        vertical-align: top;
    }
    .fileUpload input.upload {
        position: absolute;
        top: 0;
        right: 0;
        margin: 0;
        padding: 0;
        cursor: pointer;
        opacity: 0;
        filter: alpha(opacity=0);
        -moz-opacity: 0;
        -khtml-opacity: 0;
    }
    .container{
        margin-left: auto;
        margin-right: auto;
		justify-content: center;
        align-items: center;
        width: 500px;//As images should be 500px wide
	} 
    @media screen and (max-width: 500px){
        .container{
            margin-left: auto;
            margin-right: auto;
            justify-content: center;
            align-items: center;
            width: 100%
        }
    }
    .article-divider {
        margin: 15px 0;
        height: 1px;
        background: black;
        background: -webkit-gradient(linear, 0 0, 100% 0, from(white), to(white), color-stop(50%, black));
        background: -ms-linear-gradient(left, black 0%, white 100%);
        background: linear-gradient(to right, white,black, white);
        filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='black', endColorstr='white',GradientType=1 );
    } 
    .uploadErrorText{
        color:red;
        display:none;
    } 
	img{
        max-width: 100%;
        height: auto;
        width: auto\9; /* ie8 */
	}