using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using CMPE363Project.Models;

namespace CMPE363Project.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            var m = new Model1();
            return View(m.tblEmployees.ToList());
        }
        public string Delete(string del)
        {

            var m = new Model1();
            int id = Int32.Parse(del);
            var exists = m.tblEmployees.FirstOrDefault(i => i.EmpID == id);
            if (exists != null)
            {
                m.tblEmployees.Remove(exists);
                m.SaveChanges();
                return "successful";
            }
            else { return "employee not found"; }
        }

        public string Add(tblEmployee emp)
        {
            var m = new Model1();
            m.tblEmployees.Add(emp);
            m.SaveChanges();
            return "succesful";
        }

        public ActionResult Select(int? EmpID)
        {
            if (EmpID == null) return RedirectToAction("Index");
            var m = new Model1();
            var exists = m.tblEmployees.FirstOrDefault(emp => emp.EmpID == EmpID);
            var list = new List<tblEmployee>();
            if (exists != null)
            {
                list.Add(exists);
                return View("Index", list);
            }
            else
            {
                return View("Index", list);
            }
        }
    }
}