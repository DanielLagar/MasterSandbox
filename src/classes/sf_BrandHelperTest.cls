@isTest
private class sf_BrandHelperTest {
	
	@isTest static void testInit() {
		sf_BrandHelper.getBrands();
		sf_BrandHelper.getBrandSelectList();
		sf_BrandHelper.isValidBrandLabel('test');
		sf_BrandHelper.isValidBrandName('test');
	}
}