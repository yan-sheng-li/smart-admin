package com.example.sa.admin.module.business.oa.invoice.domain;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class InvoiceUpdateForm extends InvoiceAddForm {

    @Schema(description = "发票信息ID")
    @NotNull(message = "发票信息ID不能为空")
    private Long invoiceId;
}
