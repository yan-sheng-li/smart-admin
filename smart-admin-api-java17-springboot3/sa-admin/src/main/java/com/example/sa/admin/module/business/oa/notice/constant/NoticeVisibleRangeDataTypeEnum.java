package com.example.sa.admin.module.business.oa.notice.constant;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.example.sa.base.common.enumeration.BaseEnum;

@Getter
@AllArgsConstructor
public enum NoticeVisibleRangeDataTypeEnum implements BaseEnum {

    /**
     * 员工
     */
    EMPLOYEE(1, "员工"),

    /**
     * 部门
     */
    DEPARTMENT(2, "部门"),

    ;

    private final Integer value;

    private final String desc;
}
