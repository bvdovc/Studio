package sym.configurationmodel.utils
{
	public class LinearEquationsSystemUtility
	{
		private static var _extendedSystemMatrix:Array = [];
		private static var _constantTerms:Array = [];
		
		public static function get extendedSystemMatrix():Array
		{
			return _extendedSystemMatrix;
		}

		public static function get constantTerms():Array
		{
			return _constantTerms;
		}
		
		/**
		 * Create linear equation system 
		 * @param equationValues equations koefficient and constant terms value
		 * @return extended system matrix containing all values - koefficient and constant terms
		 * 
		 */		
		public static function createSystem(equationValues:Array):Matrix
		{
			var rows:int = equationValues.length;
			var columns:int = equationValues[0].length;
			
			_extendedSystemMatrix = equationValues;
			for (var i:int = 0; i < equationValues.length; i++) 
			{
				for (var j:int = 0; j <= equationValues.length; j++) 
				{
					if (j == equationValues.length)
					{
						_constantTerms[i] = equationValues[i][j];						
					}
				}
			}
			
			return new Matrix(rows, columns, _extendedSystemMatrix);
		}
		
		/**
		 * Get unique solutions for the linear equations system using Cramers' rule
		 * @param equationsSystemElements extended system matrix containing all values - koefficient and constant terms
		 * @return equations system solutions
		 * 
		 */		
		public static function applyCramersRule(equationsSystemElements:Matrix):Array
		{
			// matrix of the coefficients of the system
			var systemMatrix:Matrix = equationsSystemElements.removeColumn(equationsSystemElements.columnCount);
			var temp1:Array;
			var temp:Array;
			var systemDeterminants:Array = [];
			var systemSolutions:Array = [];
			systemDeterminants.push(systemMatrix.determinant());			
			
			for (var k:int = 0; k < systemMatrix.rowCount; k++) 
			{
				temp = new Array(systemMatrix.rowCount);
				for (var i:int = 0; i < systemMatrix.rowCount; i++) 
				{
					temp1 = new Array(systemMatrix.rowCount);
					for (var j:int = 0; j < systemMatrix.rowCount; j++) 
					{
						temp1[j] = (k == j ? constantTerms[i] : systemMatrix.matrix[i][j]);
					}
					temp[i] = temp1;
				}
				systemDeterminants.push(new Matrix(systemMatrix.rowCount, systemMatrix.rowCount, temp).determinant());
			}
			
			for (var solution:int = 0, det:int = 1; solution < systemMatrix.rowCount; solution++, det++) 
			{
				systemSolutions[solution] = systemDeterminants[det] / systemDeterminants[0];
			}
			
			return systemSolutions;
		}
	}
}
import flash.geom.Matrix3D;

class Matrix
{
	private static const MATRIX_OF_ORDER_2:int = 2;
	private static const MATRIX_OF_ORDER_3:int = 3;
	private static const MATRIX_OF_ORDER_4:int = 4;
	
	private static const SQUARE_MATRIX_ERROR:String = "Matrix must be set as square matrix. ";
	private static const SARRUS_RULE_ERROR:String = "Matrix must be set as matrix of order 3 so that Sarrus's rule can be applied to it. ";
	
	private var _rows:int = 0;
	private var _columns:int = 0;
	
	private var _matrix:Array = [];
	
	public function Matrix(rows:int, columns:int, matrix:Array)
	{
		_rows = rows;
		_columns = columns;
		
		for (var i:int = 0; i < rows; i++) 
		{
			_matrix[i] = matrix[i];
		}
		
	}
	
	public function get matrix():Array
	{
		return _matrix;
	}
	
	public function get rowCount():int
	{
		return _rows;
	}

	public function get columnCount():int
	{
		return _columns;
	}
	
	public function isSquareMatrix():Boolean
	{
		return rowCount == columnCount;
	}
	
	/**
	 * Get sign that is multiplied by minor of determinant.<br/>
	 * Together they build expression which is called - cofactor
	 * @param i row of minor
	 * @param j column of minor
	 * @return 
	 * 
	 */	
	public function cofactorSign(i:int, j:int):int
	{
		return (i + j) % 2 == 0 ? 1 : -1; 
	}
	
	/**
	 * Remove specific column from matrix 
	 * @param n column to remove
	 * @return new matrix without <code>n-th</code> column
	 * 
	 */	
	public function removeColumn(n:int):Matrix
	{
		var newMatrix:Array = [];
		var temp:Array;
		
		for (var i:int = 0; i < rowCount; i++) 
		{
			temp = new Array(columnCount - 1);
			for (var j:int = 0, y:int = 0; j < columnCount - 1; j++, y++) 	
			{
				temp[j] = matrix[i][j != n - 1 ? y : ++y];
			}
			newMatrix[i] = temp;
		}
		
		return new Matrix(rowCount, columnCount - 1, newMatrix);
	}
	
	/**
	 * Calculates determinant of the submatrix formed by deleting the m-th row and n-th column 
	 * @param m row to remove
	 * @param n column to remove
	 * @return 
	 * 
	 */	
	public function minorDeterminant(m:int, n:int):Matrix
	{
		if (!isSquareMatrix()) 
		{
			throw new Error(SQUARE_MATRIX_ERROR);
		}	
		var m1:int = rowCount - 1;
		var minor:Array = [];
		var temp:Array;
		var x:int = 0;
		var y:int = 0;
		
		for (var i:int = 0; i < rowCount; i++)
		{
			if (i == m-1) continue;
			for (var j:int = 0; j < columnCount; j++)		
			{
				if (j == n-1) continue;
				temp[y] = matrix[i][j];
				++y;
			}
			minor[x] = temp;
			++x;
		}
		
		return new Matrix(m1, m1, minor);
	}
	
	/**
	 * Sarrus' rule for finding matrix determinant.<br/>
	 * Rule is only applied to matrices of order 3 
	 * @return 
	 * 
	 */	
	public function applyRuleOfSarrus():Number
	{
		if (!isSquareMatrix() && rowCount != MATRIX_OF_ORDER_3)
		{
			throw new Error(SQUARE_MATRIX_ERROR + SARRUS_RULE_ERROR); 
		}
		var d1:Number;
		var d2:Number;
		var d3:Number;
		var d4:Number;
		var d5:Number;
		var d6:Number;
		
		d1 = matrix[0][0] * matrix[1][1] * matrix[2][2];
		d2 = matrix[0][1] * matrix[1][2] * matrix[2][0];
		d3 = matrix[0][2] * matrix[1][0] * matrix[2][1];
		d4 = matrix[0][2] * matrix[1][1] * matrix[2][0];
		d5 = matrix[0][0] * matrix[1][2] * matrix[2][1];
		d6 = matrix[0][1] * matrix[1][0] * matrix[2][2];
		
		return d1 + d2 + d3 - (d4 + d5 + d6);
	}
	
	/**
	 * Get determinant of matrix
	 * @return 
	 * 
	 */	
	public function determinant():Number
	{
		var det:Number;
		
		if (!isSquareMatrix())
		{
			throw new Error(SQUARE_MATRIX_ERROR + SARRUS_RULE_ERROR);
		}
		
		switch(this.rowCount)
		{
			case MATRIX_OF_ORDER_2:
			{
				var d1:Number;
				var d2:Number;
				d1 = matrix[0][0] * matrix[1][1];
				d2 = matrix[1][0] * matrix[0][1];
				det = d1 - d2;
				break;
			}
			case MATRIX_OF_ORDER_3:
			{
				det = applyRuleOfSarrus();
				break;
			}
			case MATRIX_OF_ORDER_4:
			{
				var v:Vector.<Number> = new Vector.<Number>;
				
				for (var i:int = 0; i < rowCount; i++) 
				{
					for (var j:int = 0; j < rowCount; j++) 
					{
						v.push(matrix[i][j]);						
					}
				}
				
				det = (new Matrix3D(v)).determinant;
				break;
			}
		}
		
		return det;
	}
	
}