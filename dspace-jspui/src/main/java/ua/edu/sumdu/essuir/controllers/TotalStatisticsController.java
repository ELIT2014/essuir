package ua.edu.sumdu.essuir.controllers;

import org.apache.log4j.Logger;
import org.dspace.app.webui.servlet.InternalErrorServlet;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.i18n.LocaleContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.LocaleResolver;
import org.springframework.web.servlet.support.RequestContextUtils;
import ua.edu.sumdu.essuir.EssuirStatistics;
import ua.edu.sumdu.essuir.YearStatistics;
import ua.edu.sumdu.essuir.service.GeneralStatisticsService;
import ua.edu.sumdu.essuir.StatisticData;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.*;

@Controller
@RequestMapping(value = "/stat")
public class TotalStatisticsController {

    @Autowired
    private GeneralStatisticsService generalStatisticsService;

    private static Logger log = Logger.getLogger(TotalStatisticsController.class);

    @RequestMapping(value = "/current", method = RequestMethod.GET)
    @ResponseBody
    public Map<String,Integer> getTotalStatistics(HttpServletRequest request){
        Map<String,Integer> stat = new HashMap<String, Integer>();
        StatisticData sd;
        try {
            org.dspace.core.Context context = org.dspace.app.webui.util.UIUtil.obtainContext(request);
            sd = EssuirStatistics.getTotalStatistic(context);
            stat.put("TotalCount",Long.valueOf(sd.getTotalCount()).intValue());
            stat.put("TotalViews", Long.valueOf(sd.getTotalViews()).intValue());
            stat.put("TotalDownloads",Long.valueOf(sd.getTotalDownloads()).intValue());
            stat.put("CurrentMonthStatisticsViews",generalStatisticsService.getCurrentMonthStatisticsViews(sd.getTotalViews()));
            stat.put("CurrentMonthStatisticsDownloads",generalStatisticsService.getCurrentMonthStatisticsDownloads(sd.getTotalDownloads()));
            stat.put("CurrentYearStatisticsViews",generalStatisticsService.getCurrentYearStatisticsViews(sd.getTotalViews()));
            stat.put("CurrentYearStatisticsDownloads",generalStatisticsService.getCurrentYearStatisticsDownloads(sd.getTotalDownloads()));
            context.complete();
        }catch (Exception ex) {
            log.error(ex.getMessage(), ex);
        }
        return stat;
    }

    @RequestMapping( value = "/pubstat", method = RequestMethod.GET)
    public String getGeneralStatistics(ModelMap model){
        model.addAttribute("listYearStatistics", generalStatisticsService.getListYearsStatistics());
        return "pub_stat";
    }
}
