package com.example.sa.admin.module.system.position.domain.form;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Data;


@Data
public class PositionUpdateForm extends PositionAddForm {

    @Schema(description = "职务ID", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotNull(message = "职务ID 不能为空")
    private Long positionId;

}