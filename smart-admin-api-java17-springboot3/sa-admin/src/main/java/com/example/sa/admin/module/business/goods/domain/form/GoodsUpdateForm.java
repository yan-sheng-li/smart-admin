package com.example.sa.admin.module.business.goods.domain.form;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class GoodsUpdateForm extends GoodsAddForm {

    @Schema(description = "商品id")
    @NotNull(message = "商品id不能为空")
    private Long goodsId;
}
