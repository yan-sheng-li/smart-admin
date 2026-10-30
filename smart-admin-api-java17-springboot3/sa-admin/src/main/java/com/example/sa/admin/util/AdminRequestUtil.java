package com.example.sa.admin.util;

import com.example.sa.admin.module.system.login.domain.RequestEmployee;
import com.example.sa.base.common.domain.RequestUser;
import com.example.sa.base.common.util.SmartRequestUtil;

public final class AdminRequestUtil {

    public static RequestEmployee getRequestUser() {
        return (RequestEmployee) SmartRequestUtil.getRequestUser();
    }

    public static Long getRequestUserId() {
        RequestUser requestUser = getRequestUser();
        return null == requestUser ? null : requestUser.getUserId();
    }

}
