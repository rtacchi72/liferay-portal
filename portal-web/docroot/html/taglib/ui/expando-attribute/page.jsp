<%
/**
 * Copyright (c) 2000-2008 Liferay, Inc. All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
%>

<%@ include file="/html/taglib/init.jsp" %>

<%@ page import="com.liferay.portlet.expando.model.ExpandoBridge"%>
<%@ page import="com.liferay.portlet.expando.model.ExpandoBridgeImpl"%>
<%@ page import="com.liferay.portlet.expando.model.ExpandoColumn"%>
<%@ page import="com.liferay.portlet.expando.model.ExpandoColumnConstants"%>
<%@ page import="com.liferay.portlet.expando.model.ExpandoTableConstants"%>
<%@ page import="com.liferay.portlet.expando.service.ExpandoColumnLocalServiceUtil"%>
<%@ page import="com.liferay.portlet.expando.service.permission.ExpandoColumnPermission"%>

<%
DateFormat dateFormatDateTime = DateFormats.getDateTime(locale, timeZone);

String randomNamespace = PwdGenerator.getPassword(PwdGenerator.KEY3, 4) + StringPool.UNDERLINE;

String className = (String)request.getAttribute("liferay-ui:expando-attribute:className");
long classPK = GetterUtil.getLong((String)request.getAttribute("liferay-ui:expando-attribute:classPK"));
boolean editable = GetterUtil.getBoolean((String)request.getAttribute("liferay-ui:expando-attribute:editable"));
String name = (String)request.getAttribute("liferay-ui:expando-attribute:name");

ExpandoBridge expandoBridge = new ExpandoBridgeImpl(className, classPK);

ExpandoColumn column = ExpandoColumnLocalServiceUtil.getColumn(className, ExpandoTableConstants.DEFAULT_TABLE_NAME, name);

int type = expandoBridge.getAttributeType(name);
Object value = expandoBridge.getAttribute(name);
%>

<c:if test="<%= ExpandoColumnPermission.contains(permissionChecker, column, ActionKeys.VIEW) %>">
	<div class="expando-attribute <%= name %>">
		<c:choose>
			<c:when test="<%= editable && ExpandoColumnPermission.contains(permissionChecker, column, ActionKeys.UPDATE) %>">
				<input type="hidden" name="<portlet:namespace />ExpandoAttributeName(<%= name %>)" value="<%= name %>" />
				<c:choose>
					<c:when test="<%= column.getType() == ExpandoColumnConstants.BOOLEAN %>">
						<%
						boolean curValue = ((Boolean)value).booleanValue();
						%>
						<input type="radio" name="<portlet:namespace />ExpandoAttribute(<%= name %>)" value="true" <%= (curValue ? "checked='checked'" : "") %> /> <liferay-ui:message key="true" />

						&nbsp;

						<input type="radio" name="<portlet:namespace />ExpandoAttribute(<%= name %>)" value="false" <%= (!curValue ? "checked='checked'" : "") %> /> <liferay-ui:message key="false" />
					</c:when>
					<c:when test="<%= column.getType() == ExpandoColumnConstants.BOOLEAN_ARRAY %>">
						<%
						boolean[] values = (boolean[])value;

						if ((value != null) && (values.length > 0)) {
							%>
							<input type="hidden" name="<portlet:namespace />ExpandoAttribute(<%= name %>)Num" value="<%= values.length %>" />
							<%

							for (int i = 0; i < values.length; i++) {
								%>
								<c:if test="<%= i > 0 %>">
									<br />
								</c:if>

								<input type="radio" name="<portlet:namespace />ExpandoAttribute(<%= name %>)_<%= i %>" value="true" <%= (values[i] ? "checked='checked'" : "") %> /> <liferay-ui:message key="true" />

								&nbsp;

								<input type="radio" name="<portlet:namespace />ExpandoAttribute(<%= name %>)_<%= i %>" value="false" <%= (!values[i] ? "checked='checked'" : "") %> /> <liferay-ui:message key="false" />
								<%
							}
						}
						else {
							%>
							<input type="hidden" name="<portlet:namespace />ExpandoAttribute(<%= name %>)Num" value="1" />

							<input type="radio" name="<portlet:namespace />ExpandoAttribute(<%= name %>)_0" value="true" /> <liferay-ui:message key="true" />

							&nbsp;

							<input type="radio" name="<portlet:namespace />ExpandoAttribute(<%= name %>)_0" value="false"checked='checked' /> <liferay-ui:message key="false" />
							<%
						}
						%>
					</c:when>
					<c:when test="<%= column.getType() == ExpandoColumnConstants.DATE %>">
						<%
						Calendar valueDate = CalendarFactoryUtil.getCalendar(timeZone, locale);

						if (value != null) {
							valueDate.setTime((Date)value);
						}
						%>

						<liferay-ui:input-date
							monthParam='<%= "ExpandoAttribute(" + name + ")Month" %>'
							monthValue='<%= valueDate.get(Calendar.MONTH) %>'
							dayParam='<%= "ExpandoAttribute(" + name + ")Day" %>'
							dayValue="<%= valueDate.get(Calendar.DATE) %>"
							yearParam='<%= "ExpandoAttribute(" + name + ")Year" %>'
							yearValue="<%= valueDate.get(Calendar.YEAR) %>"
							yearRangeStart="<%= valueDate.get(Calendar.YEAR) - 100 %>"
							yearRangeEnd="<%= valueDate.get(Calendar.YEAR) + 100 %>"
							firstDayOfWeek="<%= valueDate.getFirstDayOfWeek() - 1 %>"
							disabled="<%= false %>"
						/>

						&nbsp;

						<liferay-ui:input-time
							hourParam='<%= "ExpandoAttribute(" + name + ")Hour" %>'
							hourValue="<%= valueDate.get(Calendar.HOUR) %>"
							minuteParam='<%= "ExpandoAttribute(" + name + ")Minute" %>'
							minuteValue="<%= valueDate.get(Calendar.MINUTE) %>"
							minuteInterval="1"
							amPmParam='<%= "ExpandoAttribute(" + name + ")AmPm" %>'
							amPmValue="<%= valueDate.get(Calendar.AM_PM) %>"
							disabled="<%= false %>"
						/>
					</c:when>
					<c:when test="<%= column.getType() == ExpandoColumnConstants.DATE_ARRAY %>">
						<%
						Calendar valueDate = CalendarFactoryUtil.getCalendar(timeZone, locale);
						Date[] dates = (Date[])value;

						if ((value != null) && (dates.length > 0)) {
							%>
							<input type="hidden" name="<portlet:namespace />ExpandoAttribute(<%= name %>)Num" value="<%= dates.length %>" />
							<%

							for (int i = 0; i < dates.length; i++) {
								valueDate.setTime(dates[i]);
								%>

								<c:if test="<%= i > 0 %>">
									<br />
								</c:if>

								<liferay-ui:input-date
									monthParam='<%= "ExpandoAttribute(" + name + ")Month_" + i %>'
									monthValue="<%= valueDate.get(Calendar.MONTH) %>"
									dayParam='<%= "ExpandoAttribute(" + name + ")Day_" + i %>'
									dayValue="<%= valueDate.get(Calendar.DATE) %>"
									yearParam='<%= "ExpandoAttribute(" + name + ")Year_" + i %>'
									yearValue="<%= valueDate.get(Calendar.YEAR) %>"
									yearRangeStart="<%= valueDate.get(Calendar.YEAR) - 100 %>"
									yearRangeEnd="<%= valueDate.get(Calendar.YEAR) + 100 %>"
									firstDayOfWeek="<%= valueDate.getFirstDayOfWeek() - 1 %>"
									disabled="<%= false %>"
								/>

								&nbsp;

								<liferay-ui:input-time
									hourParam='<%= "ExpandoAttribute(" + name + ")Hour_" + i %>'
									hourValue="<%= valueDate.get(Calendar.HOUR) %>"
									minuteParam='<%= "ExpandoAttribute(" + name + ")Minute_" + i %>'
									minuteValue="<%= valueDate.get(Calendar.MINUTE) %>"
									minuteInterval="1"
									amPmParam='<%= "ExpandoAttribute(" + name + ")AmPm_" + i %>'
									amPmValue="<%= valueDate.get(Calendar.AM_PM) %>"
									disabled="<%= false %>"
								/>
								<%
							}
						}
						else {
							valueDate.setTime(new Date());
							%>
							<input type="hidden" name="<portlet:namespace />ExpandoAttribute(<%= name %>)Num" value="1" />

							<liferay-ui:input-date
								monthParam='<%= "ExpandoAttribute(" + name + ")Month_0" %>'
								monthValue="<%= valueDate.get(Calendar.MONTH) %>"
								dayParam='<%= "ExpandoAttribute(" + name + ")Day_0" %>'
								dayValue="<%= valueDate.get(Calendar.DATE) %>"
								yearParam='<%= "ExpandoAttribute(" + name + ")Year_0" %>'
								yearValue="<%= valueDate.get(Calendar.YEAR) %>"
								yearRangeStart="<%= valueDate.get(Calendar.YEAR) - 100 %>"
								yearRangeEnd="<%= valueDate.get(Calendar.YEAR) + 100 %>"
								firstDayOfWeek="<%= valueDate.getFirstDayOfWeek() - 1 %>"
								disabled="<%= false %>"
							/>

							&nbsp;

							<liferay-ui:input-time
								hourParam='<%= "ExpandoAttribute(" + name + ")Hour_0" %>'
								hourValue="<%= valueDate.get(Calendar.HOUR) %>"
								minuteParam='<%= "ExpandoAttribute(" + name + ")Minute_0" %>'
								minuteValue="<%= valueDate.get(Calendar.MINUTE) %>"
								minuteInterval="1"
								amPmParam='<%= "ExpandoAttribute(" + name + ")AmPm_0" %>'
								amPmValue="<%= valueDate.get(Calendar.AM_PM) %>"
								disabled="<%= false %>"
							/>
							<%
						}
						%>
					</c:when>
					<c:when test="<%= column.getType() == ExpandoColumnConstants.DOUBLE_ARRAY %>">
						<textarea name="<portlet:namespace />ExpandoAttribute(<%= name %>)" style="height: 105px; width: 500px;"><%= (value != null? StringUtil.merge((double[])value, "\n") : "") %></textarea>
					</c:when>
					<c:when test="<%= column.getType() == ExpandoColumnConstants.FLOAT_ARRAY %>">
						<textarea name="<portlet:namespace />ExpandoAttribute(<%= name %>)" style="height: 105px; width: 500px;"><%= (value != null? StringUtil.merge((float[])value, "\n") : "") %></textarea>
					</c:when>
					<c:when test="<%= column.getType() == ExpandoColumnConstants.INTEGER_ARRAY %>">
						<textarea name="<portlet:namespace />ExpandoAttribute(<%= name %>)" style="height: 105px; width: 500px;"><%= (value != null? StringUtil.merge((int[])value, "\n") : "") %></textarea>
					</c:when>
					<c:when test="<%= column.getType() == ExpandoColumnConstants.LONG_ARRAY %>">
						<textarea name="<portlet:namespace />ExpandoAttribute(<%= name %>)" style="height: 105px; width: 500px;"><%= (value != null? StringUtil.merge((long[])value, "\n") : "") %></textarea>
					</c:when>
					<c:when test="<%= column.getType() == ExpandoColumnConstants.FLOAT_ARRAY %>">
						<textarea name="<portlet:namespace />ExpandoAttribute(<%= name %>)" style="height: 105px; width: 500px;"><%= (value != null? StringUtil.merge((float[])value, "\n") : "") %></textarea>
					</c:when>
					<c:when test="<%= column.getType() == ExpandoColumnConstants.SHORT_ARRAY %>">
						<textarea name="<portlet:namespace />ExpandoAttribute(<%= name %>)" style="height: 105px; width: 500px;"><%= (value != null? StringUtil.merge((short[])value, "\n") : "") %></textarea>
					</c:when>
					<c:when test="<%= column.getType() == ExpandoColumnConstants.STRING_ARRAY %>">
						<textarea name="<portlet:namespace />ExpandoAttribute(<%= name %>)" style="height: 105px; width: 500px;"><%= (value != null? StringUtil.merge((String[])value, "\n") : "") %></textarea>
					</c:when>
					<c:otherwise>
						<input name="<portlet:namespace />ExpandoAttribute(<%= name %>)" size="30" type="text" value='<%= (value != null? value : "") %>' />
					</c:otherwise>
				</c:choose>
			</c:when>
			<c:otherwise>
					<%
					StringBuilder sb = new StringBuilder();

					if (type == ExpandoColumnConstants.BOOLEAN) {
						sb.append((Boolean)value);
					}
					else if (type == ExpandoColumnConstants.BOOLEAN_ARRAY) {
						sb.append(StringUtil.merge((boolean[])value));
					}
					else if (type == ExpandoColumnConstants.DATE) {
						sb.append(dateFormatDateTime.format((Date)value));
					}
					else if (type == ExpandoColumnConstants.DATE_ARRAY) {
						Date[] dates = (Date[])value;

						for (int i = 0; i < dates.length; i++) {
							if (i != 0) {
								sb.append(StringPool.COMMA_AND_SPACE);
							}

							sb.append(dateFormatDateTime.format(dates[i]));
						}
					}
					else if (type == ExpandoColumnConstants.DOUBLE) {
						sb.append((Double)value);
					}
					else if (type == ExpandoColumnConstants.DOUBLE_ARRAY) {
						sb.append(StringUtil.merge((double[])value));
					}
					else if (type == ExpandoColumnConstants.FLOAT) {
						sb.append((Float)value);
					}
					else if (type == ExpandoColumnConstants.FLOAT_ARRAY) {
						sb.append(StringUtil.merge((float[])value));
					}
					else if (type == ExpandoColumnConstants.INTEGER) {
						sb.append((Integer)value);
					}
					else if (type == ExpandoColumnConstants.INTEGER_ARRAY) {
						sb.append(StringUtil.merge((int[])value));
					}
					else if (type == ExpandoColumnConstants.LONG) {
						sb.append((Long)value);
					}
					else if (type == ExpandoColumnConstants.LONG_ARRAY) {
						sb.append(StringUtil.merge((long[])value));
					}
					else if (type == ExpandoColumnConstants.SHORT) {
						sb.append((Short)value);
					}
					else if (type == ExpandoColumnConstants.SHORT_ARRAY) {
						sb.append(StringUtil.merge((short[])value));
					}
					else if (type == ExpandoColumnConstants.STRING_ARRAY) {
						sb.append(StringUtil.merge((String[])value));
					}
					else {
						sb.append((String)value);
					}
					%>

					<span><%= sb.toString() %></span>
			</c:otherwise>
		</c:choose>
	</div>
</c:if>