<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="vo.*" %>
<%	
	//console 색 변수
	final String RESET = "\u001B[0m";
	final String BG_RED = "\u001B[41m";
	final String BG_GRAY = "\u001B[47m"; 

	//배열문법! 중요한 문법이나 자주 쓰지는 않는다.
	String[] ckMonth = request.getParameterValues("ckMonth"); //스트링 배열로 ckMont 값을 불러온다.
	int[] intCkMonth = null; // intCkMont 의 기본값을 널값으로 지정해준다.
							// int[] 대신에 ArrayList<Integer>로 써줘도 된다.
	//체크를 하기위한 배열 설정
	boolean[] mChecked = new boolean[13];
	
	//ckMonth값이 들어왔을 때 변환해서 정수배열에 추가
	if(ckMonth != null){
		intCkMonth = new int[ckMonth.length]; //ckMonth길이와 같은 수 만큼 만들고 intCkMonth안에 값을 넣어준다.
		for(int i=0; i<intCkMonth.length; i+=1){
			intCkMonth[i] = Integer.parseInt(ckMonth[i]);
			//들어온 값에 체크할수있도록 true를 넣어줌
			mChecked[intCkMonth[i]] = true;
		}
	}	
	/* if(request.getParameterValues("ckMonth") != null){ //if문을 안썼을 때는 화면을 출력하면 에러가 난다.
												//for문을 돌릴 때 null값이 들어갔으니까. null값이 들어간 이유는 string은 null값을 기본으로 가진다.
												//따라서 null값이 넘어오지않게 if문을 써서 null값이 아닐때만 for문을
												//돌릴수 있도록 해줘야한다.
		for(String s : request.getParameterValues("ckMonth")){
			System.out.println(s);
		}
	} */
	//ckMonth 값 디버깅
	if(request.getParameter("ckMonth") != null){
		for(String m : request.getParameterValues("ckMonth")){
			System.out.println(BG_GRAY + m + "<--ckMonth 에들어온 값" +RESET);
		}
	}
	//현재페이지 구하기
	int currentPage = 1;
	if(request.getParameter("currentPage") != null){
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	System.out.println(BG_GRAY + currentPage + "<--현재 currentPage 값" +RESET);
	
	//출력할 행 갯수 설정
	int rowPerPage = 10;
	//시작 행 번호
	int startRow = (currentPage - 1) * rowPerPage;
	
	//디버깅
	System.out.println(startRow + "<--startRow값");
	
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/employees";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	String sql = "";
	PreparedStatement stmt = null;
	
	if(intCkMonth == null){
		sql = "SELECT * FROM employees LIMIT ?,?";
		stmt = conn.prepareStatement(sql);
		stmt.setInt(1, startRow);
		stmt.setInt(2, rowPerPage);	
	}else{
		sql = "SELECT * FROM employees WHERE MONTH(hire_date) IN (?";
		// 쿼리에 ?의 갯수를 셋팅
		for(int i=1; i<intCkMonth.length; i+=1){
			sql += ",?";
		}
		sql += ") LIMIT ?, ?";
		
		stmt = conn.prepareStatement(sql);
		
		// 쿼리에 ?값을 셋팅
		for(int i=0; i<intCkMonth.length; i+=1){
			stmt.setInt(i+1, intCkMonth[i]);
		}
		stmt.setInt(intCkMonth.length+1, startRow);
		stmt.setInt(intCkMonth.length+2, rowPerPage);
	}
	System.out.println(BG_RED + stmt +"<--stmt 값" +RESET);
	
	
	ResultSet rs = stmt.executeQuery();
	ArrayList<EmpList> empList = new ArrayList<EmpList>();
	while(rs.next()){
		EmpList e = new EmpList();
		e.empNo = rs.getInt("emp_no");
		e.birthDate = rs.getString("birth_date");
		e.firstName = rs.getString("first_name");
		e.lastName = rs.getString("last_name");
		e.gender = rs.getString("gender");
		e.hireDate = rs.getString("hire_date");
		empList.add(e);
	}
	
	//마지막 페이지 설정
	String sql2 = "SELECT count(*) from employees";
	PreparedStatement stmt2 = conn.prepareStatement(sql2);
	ResultSet rs2 = stmt2.executeQuery();
	int totalRow = 0;
	if(rs2.next()){
		totalRow = rs2.getInt("count(*)");
	}
	
	//라스트 페이지 설정
	int lastPage = totalRow/rowPerPage;
	if(totalRow % rowPerPage != 0){
		lastPage = lastPage +1;
	}
	System.out.println(BG_RED + stmt2 +"<--stmt2 값" +RESET);
	
	// 페이지 넘길 때 체크된 월 값 같이 넘겨주기 위한 문자열
	String ckMonthNext = "";
	if(intCkMonth != null){
		for(int i=0; i<intCkMonth.length; i+=1){
			ckMonthNext += "&ckMonth=" + intCkMonth[i];
		}
	}
	System.out.println(BG_GRAY + ckMonthNext + "<--ckMonthNext" +RESET);
%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>Insert title here</title>
</head>
<body>
	<h1>사원목록</h1>
	<table>
		<tr>
			<th>empNo</th>
			<th>birthDate</th>
			<th>firstName</th>
			<th>lastName</th>
			<th>gender</th>
			<th>hireDate</th>
		</tr>
		
		<%
			for(EmpList e : empList) { //정적문법 랭귀지
		%>
				<tr>
					<td><%=e.empNo %></td>
					<td><%=e.birthDate %></td>
					<td><%=e.firstName %></td>
					<td><%=e.lastName %></td>
					<td><%=e.gender %></td>
					<td><%=e.hireDate %></td>
				</tr>
		<%
			}
		%>
	</table>
	<!-- <form action="./lastEmpList.jsp" method="get">
		<input type="checkbox" name="x" value="구">구 input name 값을 보낼때 name이 같으면 위에있는 input값만 넘어가게 된다.
												 따라서 위에서 getparm 값을 부를때 getparmvalues 로 불러줘야 두개의 값이 같이 넘어간다
		<input type="checkbox" name="x" value="디">디
		<button type="submit">검색</button>
	</form> -->
	<form action="./lastEmpList.jsp" method="get">
		<%
			// for(int i=1; i<13; i+=1){	
			//} 
			// 1월 부터 12월까지 출력은 위에 있는 for문을 쓰는것 보다는 foreach문이라는 군집을 만들어 쓰는게 맞다.
			int[] months = {1,2,3,4,5,6,7,8,9,10,11,12}; //이렇게 하는게 맞고 foreach문을 쓰는게 가독성이 높다
			for(int m : months){
		%>
			<input type="checkbox" name="ckMonth" value=<%=m%> <%if(mChecked[m]){%>checked<%} %>><%=m %>월
		<%		
			}
		%>
			<button type="submit">검색</button>
	</form>	
	<footer>
		<%
			if(currentPage > 1){
		%>
				<a href="./lastEmpList.jsp?currentPage=<%=currentPage-1%><%=ckMonthNext%>">이전</a>
		<%		
			}
			if(currentPage < lastPage){
		%>
				<a href="./lastEmpList.jsp?currentPage=<%=currentPage+1%><%=ckMonthNext%>">다음</a>
		<%		
			}
		%>	
	</footer>	
</body>
</html>