namespace CMPE363Project.Models
{
    using System;
    using System.Collections.Generic;
    using System.ComponentModel.DataAnnotations;
    using System.ComponentModel.DataAnnotations.Schema;
    using System.Data.Entity.Spatial;

    [Table("tblEmployee")]
    public partial class tblEmployee
    {
        [Key]
        public int EmpID { get; set; }

        [StringLength(20)]
        public string EmpName { get; set; }

        [StringLength(20)]
        public string EmpSurname { get; set; }

        [StringLength(20)]
        public string EmpAddress { get; set; }

        public int? EmpPhone { get; set; }
    }
}
