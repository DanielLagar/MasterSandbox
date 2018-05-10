	body {
		width: 100%;
        height: 100%;
	}

    .whereToBuyWrapperHidden{
        display:none;
    }
    .whereToBuyWrapper {
     	height:500px;
     	max-height:525px; 
     	overflow: hidden;
     	position: relative;
    }
    
    .whereToBuyLeftPannel {
        display:inline-block;
        width:80%;
        vertical-align:top;
        max-height:587px;
        /*background-color: white;*/
    }

    .mapContainer {
        overflow:hidden;
        height:100%;
        width:100%;
        vertical-align:top;
        display: inline-block;
        height: 100%;
        position: absolute;
        z-index: 1;
        top: 0;
        right: 0;
        overflow-x: hidden;
        transition: 0.5s;
    }
    
    .closeNav {
      width: 100%;
    }
    
    .openNav {
      width: 20%; 
    }
    
    .repeat-divider {
        margin: 5px 0;
        height: 1px;
        background: #000000;
        background: -webkit-gradient(linear, 0 0, 100% 0, from(white), to(white), color-stop(50%, #000000));
        background: -ms-linear-gradient(left, #000000 0%, white 100%);
        background: linear-gradient(to right, white,#000000, white);
        filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#000000', endColorstr='white',GradientType=1 );
	}
	/* DECEMBER CHANGE*/
	.pbBody {
	    height: auto;
	    /*overflow:auto;*/
	}
    
	.addressErrorOff{
		display: none;     
	}
    .addressErrorOn{
        color: red;
	    text-align: center;
	    margin: 25px auto;        
	}
	
	.whereToBuyWelcomeMessage {
	    text-align: center;
	    margin: 25px auto;
		font-size: 2em;
		font-weight: bold;
	}
	
	.locationSearchMessage {
	    text-align: center;
	    margin-bottom: 10px;
	    font-style: italic;
	}
	
	.productSearchMessage {
	    text-align: center;
	    margin-bottom: 10px;
	    font-style: italic;
	}
	
	.locationSearchInputContainer {
	    text-align: center;
	    width: 90%;
        margin: auto;
	}
	
	.searchAddressPicklist {
	    width: 100%;
	    margin-top: 10px;
	}
	
	input[type=text].locationInput, .locationInput {
	    width: 100%;    
	}
	
	[id*=searchButton]{
        background: none;
        border: none;
        width: 20%;
        height: 25px;
        text-align: right;
        font-size: 1em;
        cursor: pointer;
        color: #474646;
        position: absolute;
        top: 0;
        right: 0;
    }
    
    .productSearchContainer {
        position: relative;
        width: 90%;
        margin: auto;
    }
    
    .productSearchInput {
        width: 100%;
    }
    
    .productSearchInput::-ms-clear {
        display: none;
    }
        
    }
    
    [id*=productInput] {
        width:100%;
    }
    
    .searchedProductContainer {
        width: 90%;
        margin: auto;
        margin-bottom: 10px;
        font-size: 0.8em;
    }
    
    .addressList {
        font-size: 0.8em;
        width: 90%;
        margin: auto;
        overflow: auto;
        margin-left: 10px;
        height: 320px;
        max-height: 447px;
    }
    
    .searchAgainButton {
        color: white;
        text-decoration:none;
    }
    
    .searchAgainButtonContainer {
        text-align: center;
        margin: 25px auto;
        width: 150px;
        height: 30px;
        display: flex;
        justify-content: center;
        align-items: center;
    }
    
    .mapSlideTab {
        position: absolute;
        left: 0px;
        height: 50px;
        width: 20px;
        background-color: white;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.5em;
        -webkit-box-shadow: 3px 1px 13px 1px rgba(173,173,173,1);
        -moz-box-shadow: 3px 1px 13px 1px rgba(173,173,173,1);
        box-shadow: 3px 1px 13px 1px rgba(173,173,173,1);
    }
    
    .privacyMessageContainer {
        margin-top: 10px;
    }

    .fbkPositiveCss {
        text-decoration: none;
        color: green;
        margin-right: 25px;
        margin-left: 25px;
    }
    .fbkNegativeCss {
        text-decoration: none;
        color: red;
    }

    .cssOuterFbkDiv {
        padding: 2vh 5vh 2vh 5vh;
        position: absolute;
        width: 100%
    }
    .fbkTextDiv {
        float: left;
        font-size: 0.8em;
        margin-left: 0vw;
        white-space: nowrap;
    }
    .fbkThanksDiv {
        font-size: 0.8em;
        text-align: center;
        white-space: nowrap;
    }
    .fbkOuterDiv {
        padding: 2vh 10vh 2vh 3vh;
        position: absolute;
        width: auto;
        background-color: #FFFFFF;
    }
    @media screen and (min-width:767px) {
        /* DECEMBER CHANGE*/
        .pbBody {
            /*max-height: 587px;*/
        }
        
        .fbkPositiveCss {
            margin-right: 10px;
            margin-left: 10px;
            text-decoration: none;
            color: green;
        }
        .fbkNegativeCss {
            text-decoration: none;
            color: red;
        }
        .fbkTextDiv {
            float: left;
            font-size: 0.8em;
            white-space: nowrap;
        }
        .fbkThanksDiv {
            float: left;
            font-size: 0.8em;
            margin-left: 1vw;
            white-space: nowrap;
        }
        .fbkOuterDiv {
            padding: 2vh 5vh 2vh 5vh;
            position: absolute;
            width: auto;
            background-color: #FFFFFF;
            margin-left: 10px;
        }
        .openNav {
            width: 70%;
        }
        
        .whereToBuyLeftPannel {
            width: 30%;
        }
        
        /*.mapSlideTab {
            display: none;    
        }*/
        
        .locationSearchInputContainer {
            width: 60%;    
        }
        
        .productSearchContainer {
            width: 60%;
        }
        
        .searchedProductText {
            width: calc(100% - 50px);
            display: flex;
            justify-content: center;
            align-items: center;
        }
        
        .searchAddressPicklist {
            display: inline-block;
        }
        
        input[type=text].locationInput, .locationInput {
    	    width: 63%;
            margin-right: 2%;
	    }
	    
    	.searchAddressPicklist {
    	    width: 35%;
    	}
    }