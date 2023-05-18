<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="vo.*" %>
<%
	//인코딩
	request.setCharacterEncoding("utf-8");

	//final 변수(상수)를 사용하여 가독성을 높임
	final String RESET = "\u001B[0m"; 
	final String YELLOW = "\u001B[43m";
	
	// 파라미터값 확인
	System.out.println(request.getParameter("currentPage") + "<-- empListBySerch parm currentPage 값");
																//디버깅 설명을 적을 때 페이지이름 파라값인지 일반값인지 알수있는 적은 뒤 마지막은 출력될부분을 적는것이 보기 쉽다.
	System.out.println(request.getParameter("serchWord")+ "<-- empListBySerch parm serchWord 값");
	System.out.println(request.getParameter("rowPerPage"));

	//페이지 만들기
	//현재페이지 설정
	// 위에 널값이 나왔으니 파라미터값 null 유효성 검사 currentPage는 널값이면안됨
	// 블럭안에 int currentPage 를 사용하게 되면 블럭의 생명주기로 인해 블럭 밖에서는 currentPage를 사용할 수 없다.
	// 따라서 int currentPage 를 블럭 밖으로 빼서 선언해준다.
	int currentpage = 1;
	if(request.getParameter("currentpage") != null){
		currentpage = Integer.parseInt(request.getParameter("currentpage"));
		// ↑↑ currentPage에 값이 있을 떄 currentPage의 값을 currentPage에 넣어주는 코드
			} /* else{
				currentPage = 1;
			}*/ //원래는 위에 1값을 주지않고 else로 밑에 값을 줬지만 코드를 줄이기위해 블럭 밖에서 currentPage의 값을 1로 넣어주면 else를 사용하지않아도 괜찮아진다.
			// 기본값을 1로 설정했기때문에..
	System.out.println(currentpage + YELLOW+"<-- 현재 currentpage");
	
	//출력 할 리스트 행 갯수 설정
	int outPutPage = 10;
	
	//페이지 넘길 때 시작하는 행 번호 설정
	int startrow = (currentpage - 1) * outPutPage;
	
	//젠더 요청값 구하기
	String gender = ""; //searchWord는 스트링 값이여서 기본값이 null값이지만 if문에서 null값 공백값을 다 비교해서 하기에는 코드가 길어지니 
						// 코드를 줄이기 위해 미리 ""공백으로 바꾸어놓고 if문을 사용하면 코드를 줄일 수 있다
	if(request.getParameter("gender") != null){
		gender = request.getParameter("gender");
	}
	System.out.println(gender + "<-- 현재 gender");
	
	//searchWord 요청값 구하기
	String searchWord = "";
	if(request.getParameter("searchWord") != null){
		searchWord = request.getParameter("searchWord");
	}
	
	//입사년도 요청값 구하기
	//시작 입사년도
	String beginYear = "";
	if(request.getParameter("beginYear") != null){
		beginYear = request.getParameter("beginYear");
	}
	System.out.println(beginYear + YELLOW+"<-- 현재 beginYear");
	//끝 입사년도
	String endYear = "";
	if(request.getParameter("endYear") != null){
		endYear = request.getParameter("endYear");
	}
	System.out.println(endYear + YELLOW+"<-- 현재 endYear");
	
	
	//첫 페이지 설정 해줬으니 디비 연결
	Class.forName("org.mariadb.jdbc.Driver");
	Connection conn = DriverManager.getConnection("jdbc:mariadb://127.0.0.1:3306/employees","root","java1234");
	//sql설정하기
	/*
		SELECT
		emp_no empNo,
		birth_date birthDate,
		first_name firstName,
		last_name lastName,
		gender gender,
		hire_date hireDate
		YEAR(birth_date) byear,
		MONTH(birth_date) bmonth,
		DAY(birth_date) bday
		FROM employees
		LIMIT ?, ?;
	*/
	String sql = null;
	PreparedStatement stmt = null;
	
	//성별검색 gender 쿼리 생성
	if(gender.equals("")){ //젠더가 공백일 때
		if(!searchWord.equals("")){// searchWord 가 공백이 아니거나
			if(!beginYear.equals("") && !endYear.equals("")){ // 시작 끝 년도 두개가 모두 공백이 아닐 때
			/*
				YEAR(hire_date) BETWEEN 1980 AND 1990; SQL 문에서 짤라서 가져오기
			*/
				sql = "SELECT emp_no empNo, birth_date birthDate, first_name firstName, last_name lastName, gender gender, hire_date hireDate, YEAR(birth_date) byear, MONTH(birth_date) bmonth, DAY(birth_date) bday FROM employees where CONCAT(first_name,' ',last_name) LIKE ? and YEAR(hire_date) BETWEEN ? AND ? LIMIT ?, ?";
				stmt = conn.prepareStatement(sql);
				stmt.setString(1, "%"+searchWord+"%");
				stmt.setString(2, beginYear);
				stmt.setString(3, endYear);
				stmt.setInt(4, startrow);
				stmt.setInt(5, outPutPage);
			} else if(!beginYear.equals("")){ // 시작년도만 공백이 아닐 때 beginYear보다 hire_date가 커야한다.
				sql = "SELECT emp_no empNo, birth_date birthDate, first_name firstName, last_name lastName, gender gender, hire_date hireDate, YEAR(birth_date) byear, MONTH(birth_date) bmonth, DAY(birth_date) bday FROM employees where CONCAT(first_name,' ',last_name) LIKE ? and YEAR(hire_date) >= ? LIMIT ?, ?";
				stmt = conn.prepareStatement(sql);
				stmt.setString(1, "%"+searchWord+"%");
				stmt.setString(2, beginYear);
				stmt.setInt(3, startrow);
				stmt.setInt(4, outPutPage);
			} else if(!endYear.equals("")){ // 끝년도만 공백이 아닐 때, endYear 보다 hire_date가 작아야한다.
				sql = "SELECT emp_no empNo, birth_date birthDate, first_name firstName, last_name lastName, gender gender, hire_date hireDate, YEAR(birth_date) byear, MONTH(birth_date) bmonth, DAY(birth_date) bday FROM employees where CONCAT(first_name,' ',last_name) LIKE ? and YEAR(hire_date) <= ? LIMIT ?, ?";
				stmt = conn.prepareStatement(sql);
				stmt.setString(1, "%"+searchWord+"%");
				stmt.setString(2, endYear);
				stmt.setInt(3, startrow);
				stmt.setInt(4, outPutPage);
			}else{ //젠더가 공백이고 서치값은 있고 입사년도가 공백일 때
				sql = "SELECT emp_no empNo, birth_date birthDate, first_name firstName, last_name lastName, gender gender, hire_date hireDate, YEAR(birth_date) byear, MONTH(birth_date) bmonth, DAY(birth_date) bday FROM employees where CONCAT(first_name,' ',last_name) LIKE ? LIMIT ?, ?";
				stmt = conn.prepareStatement(sql);
				stmt.setString(1, "%"+searchWord+"%");
				stmt.setInt(2, startrow);
				stmt.setInt(3, outPutPage);
			}
		}else{ // 젠더가 공백이고 서치가 공백일때 입사년도 sql
			if(!beginYear.equals("") && !endYear.equals("")){ 
				/*
					YEAR(hire_date) BETWEEN 1980 AND 1990; SQL 문에서 짤라서 가져오기
				*/
					sql = "SELECT emp_no empNo, birth_date birthDate, first_name firstName, last_name lastName, gender gender, hire_date hireDate, YEAR(birth_date) byear, MONTH(birth_date) bmonth, DAY(birth_date) bday FROM employees where YEAR(hire_date) BETWEEN ? AND ? LIMIT ?, ?";
					stmt = conn.prepareStatement(sql);
					stmt.setString(1, beginYear);
					stmt.setString(2, endYear);
					stmt.setInt(3, startrow);
					stmt.setInt(4, outPutPage);
				} else if(!beginYear.equals("")){ // 시작년도만 공백이 아닐 때 beginYear보다 hire_date가 커야한다.
					sql = "SELECT emp_no empNo, birth_date birthDate, first_name firstName, last_name lastName, gender gender, hire_date hireDate, YEAR(birth_date) byear, MONTH(birth_date) bmonth, DAY(birth_date) bday FROM employees where YEAR(hire_date) >= ? LIMIT ?, ?";
					stmt = conn.prepareStatement(sql);
					stmt.setString(1, beginYear);
					stmt.setInt(2, startrow);
					stmt.setInt(3, outPutPage);
				} else if(!endYear.equals("")){ // 끝년도만 공백이 아닐 때, endYear 보다 hire_date가 작아야한다.
					sql = "SELECT emp_no empNo, birth_date birthDate, first_name firstName, last_name lastName, gender gender, hire_date hireDate, YEAR(birth_date) byear, MONTH(birth_date) bmonth, DAY(birth_date) bday FROM employees where YEAR(hire_date) <= ? LIMIT ?, ?";
					stmt = conn.prepareStatement(sql);
					stmt.setString(1, endYear);
					stmt.setInt(2, startrow);
					stmt.setInt(3, outPutPage);
				}else{ // 입사년도가 값이 없을 때
					sql = "SELECT emp_no empNo, birth_date birthDate, first_name firstName, last_name lastName, gender gender, hire_date hireDate, YEAR(birth_date) byear, MONTH(birth_date) bmonth, DAY(birth_date) bday FROM employees LIMIT ?, ?";
					stmt = conn.prepareStatement(sql);
					stmt.setInt(1, startrow);
					stmt.setInt(2, outPutPage);
					
				}
		}
	}else if(gender.equals("M") || gender.equals("F")){ //성별이 선택되었을 때 설정하기
			if(!searchWord.equals("")//searchWord 가 선택되었을 때
				){
				if(!beginYear.equals("") && !endYear.equals("")){ // 시작 끝 년도 두개가 모두 공백이 아닐 때
					/*
						YEAR(hire_date) BETWEEN 1980 AND 1990; SQL 문에서 짤라서 가져오기
					*/
						sql = "SELECT emp_no empNo, birth_date birthDate, first_name firstName, last_name lastName, gender gender, hire_date hireDate, YEAR(birth_date) byear, MONTH(birth_date) bmonth, DAY(birth_date) bday FROM employees where gender = ? and CONCAT(first_name,' ',last_name) LIKE ? and YEAR(hire_date) BETWEEN ? AND ? LIMIT ?, ?";
						stmt = conn.prepareStatement(sql);
						stmt.setString(1, gender);
						stmt.setString(2, "%"+searchWord+"%");
						stmt.setString(3, beginYear);
						stmt.setString(4, endYear);
						stmt.setInt(5, startrow);
						stmt.setInt(6, outPutPage);
					} else if(!beginYear.equals("")){ // 시작년도만 공백이 아닐 때 beginYear보다 hire_date가 커야한다.
						sql = "SELECT emp_no empNo, birth_date birthDate, first_name firstName, last_name lastName, gender gender, hire_date hireDate, YEAR(birth_date) byear, MONTH(birth_date) bmonth, DAY(birth_date) bday FROM employees where gender = ? and CONCAT(first_name,' ',last_name) LIKE ? and YEAR(hire_date) >= ? LIMIT ?, ?";
						stmt = conn.prepareStatement(sql);
						stmt.setString(1, gender);
						stmt.setString(2, "%"+searchWord+"%");
						stmt.setString(3, beginYear);
						stmt.setInt(4, startrow);
						stmt.setInt(5, outPutPage);
					} else if(!endYear.equals("")){ // 끝년도만 공백이 아닐 때, endYear 보다 hire_date가 작아야한다.
						sql = "SELECT emp_no empNo, birth_date birthDate, first_name firstName, last_name lastName, gender gender, hire_date hireDate, YEAR(birth_date) byear, MONTH(birth_date) bmonth, DAY(birth_date) bday FROM employees where gender = ? and CONCAT(first_name,' ',last_name) LIKE ? and YEAR(hire_date) <= ? LIMIT ?, ?";
						stmt = conn.prepareStatement(sql);
						stmt.setString(1, gender);
						stmt.setString(2, "%"+searchWord+"%");
						stmt.setString(3, endYear);
						stmt.setInt(4, startrow);
						stmt.setInt(5, outPutPage);
					} else{ //젠더 값 있고 서치값 있고 입사년도 값 없을 때
						sql = "SELECT emp_no empNo, birth_date birthDate, first_name firstName, last_name lastName, gender gender, hire_date hireDate, YEAR(birth_date) byear, MONTH(birth_date) bmonth, DAY(birth_date) bday FROM employees where gender = ? and CONCAT(first_name,' ',last_name) LIKE ? LIMIT ?, ?";
						stmt = conn.prepareStatement(sql);
						stmt.setString(1, gender);
						stmt.setString(2, "%"+searchWord+"%");
						stmt.setInt(3, startrow);
						stmt.setInt(4, outPutPage);
					}
			}else{ //젠더는 값이 있고 서치는 값이 없을때 입사년도 분기
				if(!beginYear.equals("") && !endYear.equals("")){ // 시작 끝 년도 두개가 모두 공백이 아닐 때
					/*
						YEAR(hire_date) BETWEEN 1980 AND 1990; SQL 문에서 짤라서 가져오기
					*/
						sql = "SELECT emp_no empNo, birth_date birthDate, first_name firstName, last_name lastName, gender gender, hire_date hireDate, YEAR(birth_date) byear, MONTH(birth_date) bmonth, DAY(birth_date) bday FROM employees where gender = ? and YEAR(hire_date) BETWEEN ? AND ? LIMIT ?, ?";
						stmt = conn.prepareStatement(sql);
						stmt.setString(1, gender);
						stmt.setString(2, beginYear);
						stmt.setString(3, endYear);
						stmt.setInt(4, startrow);
						stmt.setInt(5, outPutPage);
					} else if(!beginYear.equals("")){ // 시작년도만 공백이 아닐 때 beginYear보다 hire_date가 커야한다.
						sql = "SELECT emp_no empNo, birth_date birthDate, first_name firstName, last_name lastName, gender gender, hire_date hireDate, YEAR(birth_date) byear, MONTH(birth_date) bmonth, DAY(birth_date) bday FROM employees where gender = ? and YEAR(hire_date) >= ? LIMIT ?, ?";
						stmt = conn.prepareStatement(sql);
						stmt.setString(1, gender);
						stmt.setString(2, beginYear);
						stmt.setInt(3, startrow);
						stmt.setInt(4, outPutPage);
					} else if(!endYear.equals("")){ // 끝년도만 공백이 아닐 때, endYear 보다 hire_date가 작아야한다.
						sql = "SELECT emp_no empNo, birth_date birthDate, first_name firstName, last_name lastName, gender gender, hire_date hireDate, YEAR(birth_date) byear, MONTH(birth_date) bmonth, DAY(birth_date) bday FROM employees where gender = ? and YEAR(hire_date) <= ? LIMIT ?, ?";
						stmt = conn.prepareStatement(sql);
						stmt.setString(1, gender);
						stmt.setString(2, endYear);
						stmt.setInt(3, startrow);
						stmt.setInt(4, outPutPage);
					} else{ // 시작 끝 둘다 없을 때
						sql = "SELECT emp_no empNo, birth_date birthDate, first_name firstName, last_name lastName, gender gender, hire_date hireDate, YEAR(birth_date) byear, MONTH(birth_date) bmonth, DAY(birth_date) bday FROM employees where gender = ? LIMIT ?, ?";
						stmt = conn.prepareStatement(sql);
						stmt.setString(1, gender);
						stmt.setInt(2, startrow);
						stmt.setInt(3, outPutPage);
					}			
			}
		}
	//입사년도 쿼리 생성
	
	
	//디버깅
	System.out.println(stmt + "<-- stmt 값");
	ResultSet rs = stmt.executeQuery();
	
	//에리아리스트 설정, 리스트를 나오게 하자
	ArrayList<EmpList> empList = new ArrayList<EmpList>();
	while(rs.next()){
		EmpList e = new EmpList();
		e.empNo = rs.getInt("empNo");
		e.birthDate = rs.getString("birthDate");
		e.firstName = rs.getString("firstName");
		e.lastName = rs.getString("lastName");
		e.gender = rs.getString("gender");
		e.hireDate = rs.getString("hireDate");
		// 짤라온 sql문을 에리아리스트에 넣어준다.
		e.byear = rs.getInt("byear");
		e.bmonth = rs.getInt("bmonth");
		e.bday = rs.getInt("bday");
		empList.add(e);
	}
	
	//마지막 페이지 설정
	//sql설정
	/*
		SELECT count(*) from employees
	*/
	String sql2 = "SELECT count(*) from employees";
	if(!gender.equals("")){
		sql2 = "SELECT count(*) from employees where gender = '" + gender + "'";
	}
	PreparedStatement stmt2 = conn.prepareStatement(sql2);
	ResultSet rs2 = stmt2.executeQuery();
	//디버깅 확인
	System.out.println(stmt2 +"<-- stmt2 값");
	
	//토탈로우 설정.
	int totalRow = 0;
	if(rs2.next()){
		totalRow = rs2.getInt("count(*)");
	}
	//마지막페이지 출력했을 때 남는 행 있으면 어떻게 해야하는지 설정
	int lastPage = totalRow/outPutPage;
	if(totalRow % outPutPage != 0){
		lastPage = lastPage +1;
	}
	
	//나이 출력
	//캘린더 가져오기
	Calendar today = Calendar.getInstance();
	int year = today.get(Calendar.YEAR);
	int month = today.get(Calendar.MONTH);
	int day = today.get(Calendar.DATE);
%>    
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>Insert title here</title>
	<style>
		table, td, th {
			border: 1px solid #BDBDBD; 
		}
		table {
			border-collapse: collapse;
			width: 1280px;
			height: 600px;
			background-color: #F6F6F6;
			text-align: center;
			margin: 0 auto;
		}
		th{
			background-color: #FFB2D9;
			height: 50px;
		}
		.content{
			text-align: center;
			margin-top: 50px;
		}
		footer{
			width: 1280px;
			margin: 0 auto;
		}
	</style>
</head>
<body>
	<h1 style="text-align: center; font-size: 50px;"><img alt="*" src="./img/job-seeker.png" style="width: 50px; margin-right: 15px;">emp List</h1>
	<div class="content">
		<div style="margin-bottom: 20px;">
			<form action="./empList.jsp" method="get">
			<label>성별 : </label>
			<select name="gender">
			<%
				if(gender.equals("")){
			%>
					<option value="" selected="selected">선택</option>
					<option value="M">남</option>
					<option value="F">여</option>
			<%		
				}else if(gender.equals("M")){
			%>
					<option value="" >선택</option>
					<option value="M" selected="selected">남</option>
					<option value="F">여</option>
			<%							
				}else if(gender.equals("F")){
			%>
					<option value="">선택</option>
					<option value="M">남</option>
					<option value="F" selected="selected">여</option>
			<%		
				}
			%>
			</select>
			<label>이름검색 : </label>
			<input type="text" name="searchWord" value="<%=searchWord%>">
			<label>입사년도 : </label>
			<input type="number" name="beginYear" value="<%=beginYear%>">
			~
			<input type="number" name="endYear" value="<%=endYear%>">
			<button type="submit">조회</button>
		</form>
		</div>
		<table>
			<tr>
				<th>
					empNo
<%-- 					<a href="./empList.jsp?col=emp_no&aseDesc=ASC&gender=<%=gender%>">[asc]</a>
					<a href="./empList.jsp?col=emp_no&aseDesc=DESC&gender=<%=gender%>">[desc]</a> --%>
				</th>
				<th>
					birthDate
					<%-- <a href="./empList.jsp?col=birth_date&aseDesc=ASC&gender=<%=gender%>">[asc]</a>
					<a href="./empList.jsp?col=birth_date&aseDesc=DESC&gender=<%=gender%>">[desc]</a> --%>
				</th>
				<th>
					age
					<%-- <a href="./empList.jsp?col=birth_date&aseDesc=DESC&gender=<%=gender%>">[asc]</a>
					<a href="./empList.jsp?col=birth_date&aseDesc=ASC&gender=<%=gender%>">[desc]</a> --%>
				</th>
				<th>
					firstName
					<%-- <a href="./empList.jsp?col=first_name&aseDesc=ASC&gender=<%=gender%>">[asc]</a>
					<a href="./empList.jsp?col=first_name&aseDesc=DESC&gender=<%=gender%>">[desc]</a> --%>
				</th>
				<th>
					lastName
					<%-- <a href="./empList.jsp?col=last_name&aseDesc=ASC&gender=<%=gender%>">[asc]</a>
					<a href="./empList.jsp?col=last_name&aseDesc=DESC&gender=<%=gender%>">[desc]</a> --%>
				</th>
				<th>
					gender
					<%-- <a href="./empList.jsp?col=gender&aseDesc=ASC&gender=<%=gender%>">[asc]</a>
					<a href="./empList.jsp?col=gender&aseDesc=DESC&gender=<%=gender%>">[desc]</a> --%>
				</th>
				<th>
					hireDate
					<%-- <a href="./empList.jsp?col=hire_date&aseDesc=ASC&gender=<%=gender%>">[asc]</a>
					<a href="./empList.jsp?col=hire_date&aseDesc=DESC&gender=<%=gender%>">[desc]</a> --%>
				</th>
			</tr>
			<%
				for(EmpList e : empList){
			%>
			<tr>
				<td><%=e.empNo%></td>
				<td><%=e.birthDate%></td>
			<%
				// 캘린더 year 와 가져온 byear을 빼서 현재 나이 구하기			
				int age = year - e.byear;	
				if(e.bmonth < month && e.bday < day){
					// 만약 달과 일이 지났으면 +1해서 나이 계산
			%>
					<td><%=age = age+1 %></td>
			<%		
				}else{
			%>
					<td><%=age = age-1 %></td>
			<%		
				}
			%>	
				<td><%=e.firstName%></td>
				<td><%=e.lastName%></td>
				<td><img alt="*" src="./img/<%=e.gender%>.png"></td>
				<td><%=e.hireDate%></td>
			</tr>
		<%		
			}
		%>
		</table>
	</div>
	<footer>
		<%
				if(currentpage > 1){
			%>
					<a href="./empList.jsp?currentpage=<%=currentpage-1%>&gender=<%=gender%>&searchWord=<%=searchWord%>&beginYear=<%=beginYear%>&endYear=<%=endYear%>"style="float: left; padding-left: 10px;"><img alt="+" src="./img/next1.png"></a>
			<%		
				}
				if(currentpage < lastPage){
			%>
					<div style="margin-top: 30px; font-size: 25px; text-align: center;" ><%=currentpage %> 페이지	
					<a href="./empList.jsp?currentpage=<%=currentpage+1%>&gender=<%=gender%>&searchWord=<%=searchWord%>&beginYear=<%=beginYear%>&endYear=<%=endYear%>"style="float: right; padding-right: 10px;"><img alt="+" src="./img/next.png"></a></div>
			<%		
				}
			%>
	</footer>
</body>
</html>