package  {
	public class weatherCode {
		public var givenRange: Boolean;
		public var baseCode: int;
		public var maxCode: int;

		public function weatherCode(base: int, max: int = null) {
			// constructor code
			this.baseCode = base;
			if(max != null){
				this.maxCode = max;
				this.givenRange = true;
			}
		}
		
		public function compare(targetValue: int): Boolean {
			var result: Boolean = false;
			if(givenRange){
				if(targetValue >= baseCode && targetValue < maxCode + 1){
					result = true;
				}
			}else{
				if(targetValue == baseCode){
					result = true;
				}
			}
			return result;
		}

	}
	
}
