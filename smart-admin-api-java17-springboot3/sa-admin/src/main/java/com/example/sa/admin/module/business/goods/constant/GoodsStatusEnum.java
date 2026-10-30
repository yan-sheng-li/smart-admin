package com.example.sa.admin.module.business.goods.constant;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.example.sa.base.common.enumeration.BaseEnum;

@AllArgsConstructor
@Getter
public enum GoodsStatusEnum implements BaseEnum {

    /**
     * 1 预约中
     */
    APPOINTMENT(1, "预约中"),

    /**
     * 2 售卖
     */
    SELL(2, "售卖中"),

    /**
     * 3 售罄
     */
    SELL_OUT(3, "售罄"),

    ;

    private final Integer value;

    private final String desc;
}
