package com.example.sa.admin.module.business.category.constant;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.example.sa.base.common.enumeration.BaseEnum;

@AllArgsConstructor
@Getter
public enum CategoryTypeEnum implements BaseEnum {

    /**
     * 1 商品
     */
    GOODS(1, "商品"),

    /**
     * 2 自定义
     */
    CUSTOM(2, "自定义"),

    ;

    private final Integer value;

    private final String desc;
}
