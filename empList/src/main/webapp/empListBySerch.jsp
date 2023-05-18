<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="vo.*" %>
<%
	// Controller Later : 요청처리
	// 파라미터값 : 현재페이지(String -> Integer -> int) , 검색단어(String)
	
	// 파라미터값 확인
	System.out.println(request.getParameter("currentPage") + "<-- empListBySerch parm currentPage 값");
																//디버깅 설명을 적을 때 페이지이름 파라값인지 일반값인지 알수있는 적은 뒤 마지막은 출력될부분을 적는것이 보기 쉽다.
	System.out.println(request.getParameter("serchWord")+ "<-- empListBySerch parm serchWord 값");
	System.out.println(request.getParameter("rowPerPage"));
	
	// 위에 널값이 나왔으니 파라미터값 null 유효성 검사 currentPage는 널값이면안됨
	// 블럭안에 int currentPage 를 사용하게 되면 블럭의 생명주기로 인해 블럭 밖에서는 currentPage를 사용할 수 없다.
	// 따라서 int currentPage 를 블럭 밖으로 빼서 선언해준다.
	int currentPage = 1;
	if(request.getParameter("currentPage") != null){
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
		// ↑↑ currentPage에 값이 있을 떄 currentPage의 값을 currentPage에 넣어주는 코드
	} /* else{
		currentPage = 1;
	}*/ //원래는 위에 1값을 주지않고 else로 밑에 값을 줬지만 코드를 줄이기위해 블럭 밖에서 currentPage의 값을 1로 넣어주면 else를 사용하지않아도 괜찮아진다.
	// 기본값을 1로 설정했기때문에..
	
	String searchWord = ""; //searchWord는 스트링 값이여서 기본값이 null값이지만 if문에서 null값 공백값을 다 비교해서 하기에는 코드가 길어지니 
							// 코드를 줄이기 위해 미리 ""공백으로 바꾸어놓고 if문을 사용하면 코드를 줄일 수 있다.
	if(request.getParameter("searchWord") != null){
		searchWord = request.getParameter("searchWord");
	}
	
	System.out.println(currentPage + "<-- empListBySerch currentPage 값");
	System.out.println(searchWord+ "<-- empListBySerch serchWord 값");
	
		
	int rowPerPage = 10; // 출력할 행의 수를 정해준다.
	if(request.getParameter("rowPerPage") != null){ 
		rowPerPage = Integer.parseInt(request.getParameter("rowPerPage"));
	}
	System.out.println(currentPage + "<-- empListBySerch currentPage 값");
	//디버깅 설명을 적을 때 페이지이름 파라값인지 일반값인지 알수있는 적은 뒤 마지막은 출력될부분을 적는것이 보기 쉽다.
	System.out.println(searchWord + "<-- empListBySerch serchWord 값");
	System.out.println(rowPerPage + "<-- empListBySerch rowPerPage 값");
	
	
	// Model Layer : 모델값 생성하기 까지
	// controller layer의 결과 변수(currentPage, searchWord)의 모델을 생성하기 위해 필요한 변수추가
	// controller layer에 있는 currentPage 와 searchWord의 값을 어떤부분들에서 사용할것인지 생각하고 결과 변수를 여기서 가공해준다.
	int startRow = (currentPage -1) * rowPerPage; //페이지당 시작하는 행을 구해준다.
	/*
		currentpage     rowperpage   startRow
			1				10			0
			2				10			10				
	*/
	System.out.println(startRow + "<-- empListBySerch startRow 값");
	
	//DB호출에 변수 생성
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/employees";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	//동작쿼리
	String sql = null;
	PreparedStatement stmt = null;

	System.out.println(stmt + "<-- empListBySerch stmt 완성된 쿼리문");
	
	ResultSet rs = stmt.executeQuery();
	
	// 일반적 자료구조(모델)로 변경
	ArrayList<EmpList> empList = new ArrayList<EmpList>();
	while(rs.next()){
		EmpList emp = new EmpList();
		emp.empNo = rs.getInt("empNo");
		emp.birthDate = rs.getString("birthDate");
		emp.firstName = rs.getString("firstName");
		emp.lastName = rs.getString("lastName");
		emp.gender = rs.getString("gender");
		emp.hireDate = rs.getString("hireDate");
		emp.byear = rs.getInt("byear");
		emp.bmonth = rs.getInt("bmonth");
		emp.bday = rs.getInt("bday");
		empList.add(emp);
	}
	
	// 모델값 디버깅
	System.out.println(empList.size() + "<-- empListBySerch size");
	for(EmpList e : empList){
		System.out.println(e.firstName + " " + e.lastName);
	}
	
	// 두번째 모델값
	String sql2 = "SELECT count(*) from employees";
	PreparedStatement stmt2 = conn.prepareStatement(sql2);
	ResultSet rs2 = stmt2.executeQuery();
	//토탈로우 설정.
	int totalRow = 0;
	if(rs2.next()){
		totalRow = rs2.getInt("count(*)");
	}
	//마지막페이지 출력했을 때 남는 행 있으면 어떻게 해야하는지 설정
	int lastPage = totalRow/rowPerPage;
	if(totalRow % rowPerPage != 0){
		lastPage = lastPage +1;
	}
	
	//나이 출력
	//캘린더 가져오기
	Calendar today = Calendar.getInstance();
	int year = today.get(Calendar.YEAR);
	int month = today.get(Calendar.MONTH);
	int day = today.get(Calendar.DATE);
	
	// View Layer
	
%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>empListBySerch</title>
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
				<form action="./empListBySerch.jsp" method="get">
					<input type="text" name="serchWord">
					<select name="rowPerPage">
						<option value="10">10개씩</option>
						<option value="5">5개씩</option>
						<option value="10">10개씩</option>
						<option value="15">15개씩</option>
						<option value="20">20개씩</option>
						<option value="25">25개씩</option>
						<option value="30">30개씩</option>
					</select>
					<button type="submit">선택</button>
				</form>
			</div>
			<table>
				<tr>
					<th>empNo</th>
					<th>birthDate</th>
					<th>age</th>
					<th>firstName</th>
					<th>lastName</th>
					<th>gender</th>
					<th>hireDate</th>
				</tr>
				<%
					for(EmpList emp : empList){
				%>
				<tr>
					<td><%=emp.empNo%></td>
					<td><%=emp.birthDate%></td>
				<%
					// 캘린더 year 와 가져온 byear을 빼서 현재 나이 구하기			
					int age = year - emp.byear;	
					if(emp.bmonth < month && emp.bday < day){
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
					<td><%=emp.firstName%></td>
					<td><%=emp.lastName%></td>
					<td><img alt="*" src="./img/<%=emp.gender%>.png"></td>
					<td><%=emp.hireDate%></td>
				</tr>
			<%		
				}
			%>
			</table>
		</div>
		<footer>
			<%
					if(currentPage > 1){
				%>
						<a href="./empListBySerch.jsp?currentpage=<%=currentPage-1%>"style="float: left; padding-left: 10px;"><img alt="+" src="./img/next1.png"></a>
				<%		
					}
					if(currentPage < lastPage){
				%>
						<div style="margin-top: 30px; font-size: 25px; text-align: center;" ><%=currentPage %> 페이지	
						<a href="./empListBySerch.jsp?currentpage=<%=currentPage+1%>"style="float: right; padding-right: 10px;"><img alt="+" src="./img/next.png"></a></div>
				<%		
					}
				%>
			</footer>
		</div>
</body>
</html>